[CmdletBinding()]
param(
    [ValidateSet('auto', 'docker', 'podman')]
    [string]$Engine = 'auto',

    [switch]$KeepContainer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# PostgreSQL 16.6 Official Image, fijada por manifest list digest. El dialecto
# del DDL usa capacidades de PostgreSQL 16, no una decisión de motor productivo.
$Image = 'docker.io/library/postgres:16.6-bookworm@sha256:557fea37a744d5f4c8faab304b0a90858b53ab119735a88c131fd19dab802f36'
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$SchemaPath = Join-Path $RepoRoot 'schemas/core_schema.sql'
$SqlRoot = Join-Path $PSScriptRoot 'sql'
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("iqg-pg16-" + [guid]::NewGuid().ToString('N'))
$LogRoot = Join-Path $TempRoot 'logs'
$ContainerName = 'iqg-pg16-' + [guid]::NewGuid().ToString('N').Substring(0, 12)
$script:ContainerEngine = $null
$script:ContainerName = $ContainerName

$Matrix = [ordered]@{
    A = $false; B = $false; C = $false; D = $false; E = $false; F = $false
    G = $false; H = $false; I = $false; J = $false; K = $false; L = $false
    M = $false; N = $false; O = $false; P = $false; Q = $false; R = $false
    S = $false; T = $false; U = $false; V = $false; W = $false
}

function Write-MatrixPass {
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][string]$Detail)
    $Matrix[$Id] = $true
    Write-Host ("[{0}] PASS - {1}" -f $Id, $Detail)
}

function Invoke-Engine {
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $output = @(& $script:ContainerEngine @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    $text = ($output | Out-String).TrimEnd()

    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "Container command failed ($exitCode): $script:ContainerEngine $($Arguments -join ' ')`n$text"
    }

    [pscustomobject]@{
        ExitCode = $exitCode
        Text = $text
    }
}

function Write-TemporarySql {
    param([Parameter(Mandatory)][string]$Sql, [Parameter(Mandatory)][string]$Name)
    $path = Join-Path $TempRoot $Name
    [System.IO.File]::WriteAllText($path, $Sql, [System.Text.UTF8Encoding]::new($false))
    return $path
}

function Copy-SqlToContainer {
    param([Parameter(Mandatory)][string]$Path)
    $inside = '/tmp/iqg-' + [guid]::NewGuid().ToString('N') + '.sql'
    Invoke-Engine -Arguments @('cp', $Path, ("{0}:{1}" -f $script:ContainerName, $inside)) | Out-Null
    return $inside
}

function Remove-ContainerFile {
    param([Parameter(Mandatory)][string]$Path)
    Invoke-Engine -Arguments @('exec', $script:ContainerName, 'rm', '-f', $Path) -AllowFailure | Out-Null
}

function Invoke-PsqlFile {
    param(
        [Parameter(Mandatory)][string]$Case,
        [Parameter(Mandatory)][string]$Path,
        [string]$Database = 'iqg_runtime',
        [string]$User = 'postgres',
        [switch]$ExpectFailure,
        [string]$ExpectedPattern
    )

    $inside = Copy-SqlToContainer -Path $Path
    try {
        $result = Invoke-Engine -Arguments @(
            'exec', $script:ContainerName,
            'psql', '-X', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose',
            '-h', '127.0.0.1', '-U', $User, '-d', $Database, '-f', $inside
        ) -AllowFailure
        $safeCase = ($Case -replace '[^A-Za-z0-9._-]', '_')
        [System.IO.File]::WriteAllText(
            (Join-Path $LogRoot ("{0}.log" -f $safeCase)),
            $result.Text,
            [System.Text.UTF8Encoding]::new($false)
        )

        if ($ExpectFailure) {
            if ($result.ExitCode -eq 0) {
                throw "Expected failure did not fail: $Case"
            }
            if ($ExpectedPattern -and $result.Text -notmatch $ExpectedPattern) {
                throw "Expected failure for $Case did not match '$ExpectedPattern':`n$($result.Text)"
            }
            Write-Host ("[EXPECTED FAILURE] {0}" -f $Case)
            return $result
        }

        if ($result.ExitCode -ne 0) {
            throw "SQL case failed: $Case`n$($result.Text)"
        }
        Write-Host ("[PASS] {0}" -f $Case)
        return $result
    }
    finally {
        Remove-ContainerFile -Path $inside
    }
}

function Invoke-PsqlText {
    param(
        [Parameter(Mandatory)][string]$Case,
        [Parameter(Mandatory)][string]$Sql,
        [string]$Database = 'postgres',
        [string]$User = 'postgres',
        [switch]$ExpectFailure,
        [string]$ExpectedPattern
    )

    $path = Write-TemporarySql -Sql $Sql -Name (([guid]::NewGuid().ToString('N')) + '.sql')
    try {
        return Invoke-PsqlFile -Case $Case -Path $path -Database $Database -User $User -ExpectFailure:$ExpectFailure -ExpectedPattern $ExpectedPattern
    }
    finally {
        Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    }
}

function New-TestDatabase {
    param([Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9_]*$')][string]$Name)
    Invoke-PsqlText -Case ("create_database_{0}" -f $Name) -Sql ("CREATE DATABASE {0} OWNER iqg_test_admin;" -f $Name) | Out-Null
}

function Start-PsqlTask {
    param(
        [Parameter(Mandatory)][string]$Case,
        [Parameter(Mandatory)][string]$Path,
        [string]$Database = 'iqg_runtime',
        [string]$User = 'postgres'
    )

    $inside = Copy-SqlToContainer -Path $Path
    $safeCase = ($Case -replace '[^A-Za-z0-9._-]', '_')
    $stdout = Join-Path $LogRoot ("{0}.stdout.log" -f $safeCase)
    $stderr = Join-Path $LogRoot ("{0}.stderr.log" -f $safeCase)
    $arguments = @(
        'exec', $script:ContainerName,
        'psql', '-X', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose',
        '-h', '127.0.0.1', '-U', $User, '-d', $Database, '-f', $inside
    )
    $process = Start-Process -FilePath $script:ContainerEngine -ArgumentList $arguments -NoNewWindow -PassThru `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    return [pscustomobject]@{
        Case = $Case; Process = $process; InsidePath = $inside; StdOut = $stdout; StdErr = $stderr
    }
}

function Complete-PsqlTask {
    param([Parameter(Mandatory)]$Task)
    $Task.Process.WaitForExit()
    $text = ''
    if (Test-Path -LiteralPath $Task.StdOut) { $text += [System.IO.File]::ReadAllText($Task.StdOut) }
    if (Test-Path -LiteralPath $Task.StdErr) { $text += [System.IO.File]::ReadAllText($Task.StdErr) }
    Remove-ContainerFile -Path $Task.InsidePath
    return [pscustomobject]@{ Case = $Task.Case; ExitCode = $Task.Process.ExitCode; Text = $text }
}

function Assert-TaskOutcome {
    param(
        [Parameter(Mandatory)]$Task,
        [Parameter(Mandatory)][bool]$ShouldSucceed
    )
    if ($ShouldSucceed -and $Task.ExitCode -ne 0) {
        throw "Concurrent SQL case failed: $($Task.Case)`n$($Task.Text)"
    }
    if (-not $ShouldSucceed -and $Task.ExitCode -eq 0) {
        throw "Concurrent SQL case unexpectedly succeeded: $($Task.Case)"
    }
}

function Invoke-ConcurrentPair {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string]$PathA,
        [Parameter(Mandatory)][string]$PathB,
        [string]$UserA = 'postgres',
        [string]$UserB = 'postgres'
    )

    $taskA = Start-PsqlTask -Case ("{0}_A" -f $Label) -Path $PathA -User $UserA
    Start-Sleep -Milliseconds 500
    $watchB = [System.Diagnostics.Stopwatch]::StartNew()
    $taskB = Start-PsqlTask -Case ("{0}_B" -f $Label) -Path $PathB -User $UserB
    $resultA = Complete-PsqlTask -Task $taskA
    $resultB = Complete-PsqlTask -Task $taskB
    $watchB.Stop()
    return [pscustomobject]@{ A = $resultA; B = $resultB; BElapsedSeconds = $watchB.Elapsed.TotalSeconds }
}

function Get-ContainerRuntime {
    param([string]$Requested)
    $candidates = if ($Requested -eq 'auto') { @('docker', 'podman') } else { @($Requested) }
    foreach ($candidate in $candidates) {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($null -eq $command) { continue }
        $probe = & $command.Source info 2>&1
        if ($LASTEXITCODE -eq 0) { return $command.Source }
    }
    throw 'No se encontró Docker/Podman operativo. Instale o inicie uno fuera de este repositorio; el runner no instala dependencias.'
}

try {
    if (-not (Test-Path -LiteralPath $SchemaPath)) {
        throw "No existe el DDL esperado: $SchemaPath"
    }
    New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null
    $script:ContainerEngine = Get-ContainerRuntime -Requested $Engine
    Write-Host ("PG16 image: {0}" -f $Image)
    Write-Host ("Container engine: {0}" -f $script:ContainerEngine)

    $runArgs = @(
        'run', '-d', '--name', $script:ContainerName,
        '-e', 'POSTGRES_HOST_AUTH_METHOD=trust',
        '-e', 'POSTGRES_DB=postgres',
        '-e', 'POSTGRES_USER=postgres'
    )
    if (-not $KeepContainer) { $runArgs += '--rm' }
    $runArgs += $Image
    Invoke-Engine -Arguments $runArgs | Out-Null

    $ready = $false
    foreach ($attempt in 1..60) {
        $probe = Invoke-Engine -Arguments @('exec', $script:ContainerName, 'pg_isready', '-h', '127.0.0.1', '-U', 'postgres', '-d', 'postgres') -AllowFailure
        if ($probe.ExitCode -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 1
    }
    if (-not $ready) { throw 'PostgreSQL 16 no alcanzó estado listo en 60 segundos.' }

    Invoke-PsqlText -Case 'create_test_installer' -Sql @'
CREATE ROLE iqg_test_admin LOGIN CREATEROLE NOSUPERUSER NOCREATEDB NOREPLICATION NOBYPASSRLS NOINHERIT;
'@ | Out-Null

    # B: se inyecta un error inmediatamente antes del COMMIT. La ausencia de
    # roles/esquemas IQG posteriores prueba que el bootstrap completo revierte.
    New-TestDatabase -Name 'iqg_rollback_probe'
    $schemaText = [System.IO.File]::ReadAllText($SchemaPath)
    if ($schemaText -notmatch 'COMMIT;\s*$') { throw 'El DDL no termina en COMMIT; no se puede inyectar rollback de forma segura.' }
    $rollbackText = [regex]::Replace($schemaText, 'COMMIT;\s*$', "SELECT 1 / 0;`nCOMMIT;")
    $rollbackPath = Write-TemporarySql -Sql $rollbackText -Name 'rollback_probe.sql'
    Invoke-PsqlFile -Case 'B_rollback_injected_failure' -Path $rollbackPath -Database 'iqg_rollback_probe' -User 'iqg_test_admin' -ExpectFailure | Out-Null
    Remove-Item -LiteralPath $rollbackPath -Force -ErrorAction SilentlyContinue
    Invoke-PsqlText -Case 'B_assert_rollback' -Database 'iqg_rollback_probe' -Sql @'
DO $rollback_assert$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname IN ('iqg_core', 'iqg_fiscal'))
       OR EXISTS (SELECT 1 FROM pg_roles WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')) THEN
        RAISE EXCEPTION 'El DDL dejó estado IQG tras rollback inyectado';
    END IF;
END;
$rollback_assert$;
'@ | Out-Null
    Write-MatrixPass -Id 'B' -Detail 'fallo inyectado revierte roles y esquemas IQG'

    New-TestDatabase -Name 'iqg_runtime'
    Invoke-PsqlFile -Case 'A_clean_postgresql16_install' -Path $SchemaPath -Database 'iqg_runtime' -User 'iqg_test_admin' | Out-Null
    Write-MatrixPass -Id 'A' -Detail 'DDL instala y confirma en PostgreSQL 16 limpio'

    Invoke-PsqlFile -Case 'QA_support' -Path (Join-Path $SqlRoot '00_test_support.sql') | Out-Null
    Invoke-PsqlFile -Case 'E_authorized_bootstrap' -Path (Join-Path $SqlRoot '01_bootstrap_positive.sql') -User 'qa_bootstrap' | Out-Null
    Invoke-PsqlFile -Case 'E_forged_guc_rejected' -Path (Join-Path $SqlRoot 'negative/untrusted_bootstrap_guc.sql') -User 'qa_untrusted' | Out-Null
    Invoke-PsqlFile -Case 'E_direct_bootstrap_table_denied' -Path (Join-Path $SqlRoot 'negative/bootstrap_direct_table.sql') -User 'qa_bootstrap' -ExpectFailure | Out-Null
    Write-MatrixPass -Id 'E' -Detail 'bootstrap autorizado exige session_user con capacidad y niega GUC/direct table'

    Invoke-PsqlFile -Case 'G_generic_2x2_fixture' -Path (Join-Path $SqlRoot '02_fixture.sql') | Out-Null
    Write-MatrixPass -Id 'G' -Detail 'fixture genérico crea 2 empresas x 2 sucursales'
    Invoke-PsqlFile -Case 'H_no_context_read' -Path (Join-Path $SqlRoot 'negative/no_context_read.sql') | Out-Null
    Invoke-PsqlFile -Case 'C_to_T_preassertions' -Path (Join-Path $SqlRoot '03_assertions_pre.sql') | Out-Null
    Write-MatrixPass -Id 'C' -Detail 'ACL, roles y ownership se verifican en catálogo PostgreSQL'
    Write-MatrixPass -Id 'D' -Detail 'rol efectivo y session_user se verifican bajo SECURITY DEFINER'
    Write-MatrixPass -Id 'F' -Detail 'todas las tablas IQG verificadas con FORCE RLS'
    Write-MatrixPass -Id 'H' -Detail 'sin contexto y con otra unidad no se exponen filas'
    Write-MatrixPass -Id 'L' -Detail 'roles y permisos base son idempotentes'
    Write-MatrixPass -Id 'M' -Detail 'UPDATE no semántico no revalida dominio sin cambio'
    Write-MatrixPass -Id 'Q' -Detail 'caja conserva consistencia con pago'
    Write-MatrixPass -Id 'R' -Detail 'sello de servidor y auditoría operativa se verifican'
    Write-MatrixPass -Id 'S' -Detail 'anonimización de cliente y redacción de auditoría se verifican'
    Write-MatrixPass -Id 'T' -Detail 'capa fiscal separada, snapshot y outbox se verifican'

    Invoke-PsqlFile -Case 'I_cross_scope_write_denied' -Path (Join-Path $SqlRoot 'negative/cross_scope_write.sql') -ExpectFailure | Out-Null
    Write-MatrixPass -Id 'I' -Detail 'escritura cross-company/cross-branch se rechaza'
    Invoke-PsqlFile -Case 'N_bad_operacion_line_unit_denied' -Path (Join-Path $SqlRoot 'negative/bad_operacion_line_unit.sql') -ExpectFailure | Out-Null
    Write-MatrixPass -Id 'N' -Detail 'unidad incompatible de línea de operación se rechaza'
    Invoke-PsqlFile -Case 'R_price_append_only' -Path (Join-Path $SqlRoot 'negative/append_only_price.sql') -ExpectFailure | Out-Null
    Invoke-PsqlFile -Case 'R_audit_immutable' -Path (Join-Path $SqlRoot 'negative/audit_mutation.sql') -ExpectFailure | Out-Null
    Invoke-PsqlFile -Case 'T_factura_without_lines_denied' -Path (Join-Path $SqlRoot 'negative/invalid_factura_without_lines.sql') -ExpectFailure | Out-Null

    $provisionPair = Invoke-ConcurrentPair -Label 'O_provision_same_key' `
        -PathA (Join-Path $SqlRoot 'concurrency/provision_same_key.sql') `
        -PathB (Join-Path $SqlRoot 'concurrency/provision_same_key.sql') `
        -UserA 'qa_bootstrap' -UserB 'qa_bootstrap'
    Assert-TaskOutcome -Task $provisionPair.A -ShouldSucceed $true
    Assert-TaskOutcome -Task $provisionPair.B -ShouldSucceed $true

    $pricePair = Invoke-ConcurrentPair -Label 'O_price_successor' `
        -PathA (Join-Path $SqlRoot 'concurrency/price_successor_a.sql') `
        -PathB (Join-Path $SqlRoot 'concurrency/price_successor_b.sql')
    if ((@($pricePair.A, $pricePair.B) | Where-Object { $_.ExitCode -eq 0 }).Count -ne 1) {
        throw "La carrera de precio debe tener exactamente un ganador.`nA: $($pricePair.A.Text)`nB: $($pricePair.B.Text)"
    }
    Write-MatrixPass -Id 'O' -Detail 'idempotencia concurrente y cadena única de precios verificadas'

    $paymentPair = Invoke-ConcurrentPair -Label 'P_payment_reversal' `
        -PathA (Join-Path $SqlRoot 'concurrency/payment_reversal_a.sql') `
        -PathB (Join-Path $SqlRoot 'concurrency/payment_reversal_b.sql')
    if ((@($paymentPair.A, $paymentPair.B) | Where-Object { $_.ExitCode -eq 0 }).Count -ne 1) {
        throw "La carrera de reverso debe tener exactamente un ganador.`nA: $($paymentPair.A.Text)`nB: $($paymentPair.B.Text)"
    }
    Write-MatrixPass -Id 'P' -Detail 'reversos concurrentes no exceden el pago padre'

    $lockPair = Invoke-ConcurrentPair -Label 'U_advisory_lock' `
        -PathA (Join-Path $SqlRoot 'concurrency/advisory_lock_a.sql') `
        -PathB (Join-Path $SqlRoot 'concurrency/advisory_lock_b.sql')
    Assert-TaskOutcome -Task $lockPair.A -ShouldSucceed $true
    Assert-TaskOutcome -Task $lockPair.B -ShouldSucceed $true
    if ($lockPair.BElapsedSeconds -lt 1.5) {
        throw "El segundo advisory lock no esperó el bloqueo corporativo: $($lockPair.BElapsedSeconds)s"
    }
    Write-MatrixPass -Id 'U' -Detail 'advisory lock corporativo serializa sesiones concurrentes'

    $deadlockPair = Invoke-ConcurrentPair -Label 'V_deadlock' `
        -PathA (Join-Path $SqlRoot 'concurrency/deadlock_a.sql') `
        -PathB (Join-Path $SqlRoot 'concurrency/deadlock_b.sql')
    if ((@($deadlockPair.A, $deadlockPair.B) | Where-Object { $_.ExitCode -eq 0 }).Count -ne 1 -or (($deadlockPair.A.Text + $deadlockPair.B.Text) -notmatch '40P01|deadlock detected')) {
        throw "El deadlock intencional no produjo exactamente un abort 40P01.`nA: $($deadlockPair.A.Text)`nB: $($deadlockPair.B.Text)"
    }
    Write-MatrixPass -Id 'V' -Detail 'deadlock intencional aborta una sola transacción'

    Invoke-PsqlFile -Case 'O_to_V_postconditions' -Path (Join-Path $SqlRoot '04_postconditions.sql') | Out-Null

    # W: backup/restauración completa y nueva instalación en otra base, sin
    # tratar el DDL como migración reejecutable sobre una base ya poblada.
    $backupPath = '/tmp/iqg-runtime.dump'
    Invoke-Engine -Arguments @('exec', $script:ContainerName, 'pg_dump', '-Fc', '-h', '127.0.0.1', '-U', 'postgres', '-d', 'iqg_runtime', '-f', $backupPath) | Out-Null
    New-TestDatabase -Name 'iqg_restore_probe'
    Invoke-Engine -Arguments @('exec', $script:ContainerName, 'pg_restore', '-h', '127.0.0.1', '-U', 'postgres', '-d', 'iqg_restore_probe', $backupPath) | Out-Null
    Invoke-PsqlFile -Case 'W_restore_assertions' -Path (Join-Path $SqlRoot 'restore_assertions.sql') -Database 'iqg_restore_probe' | Out-Null
    New-TestDatabase -Name 'iqg_reexecution_probe'
    # La primera instalación ya prueba un instalador no superusuario. En esta
    # segunda base las identidades IQG existen globalmente por definición; se
    # usa el superusuario efímero para recrear el préstamo temporal de owner y
    # demostrar que no queda una membresía residual entre instalaciones.
    Invoke-PsqlFile -Case 'W_clean_reexecution' -Path $SchemaPath -Database 'iqg_reexecution_probe' -User 'postgres' | Out-Null
    Write-MatrixPass -Id 'W' -Detail 'dump/restore y nueva instalación limpia verificadas'

    Invoke-PsqlFile -Case 'J_K_active_state' -Path (Join-Path $SqlRoot '05_active_state.sql') | Out-Null
    Write-MatrixPass -Id 'J' -Detail 'usuario y membresía inactivos bloquean acceso'
    Write-MatrixPass -Id 'K' -Detail 'sucursal y empresa inactivas bloquean acceso'

    $failed = @($Matrix.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key })
    if ($failed.Count -gt 0) { throw "Matriz incompleta: $($failed -join ', ')" }
    Write-Host 'PG16_MATRIX=PASS'
}
catch {
    Write-Error ("PG16_MATRIX=FAIL`n{0}" -f $_.Exception.Message)
    exit 1
}
finally {
    if ($script:ContainerEngine -and -not $KeepContainer) {
        Invoke-Engine -Arguments @('rm', '-f', $script:ContainerName) -AllowFailure | Out-Null
    }
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
