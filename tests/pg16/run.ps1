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
$BootstrapPath = Join-Path $RepoRoot 'schemas/bootstrap_roles.sql'
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

function New-InjectedSql {
    param(
        [Parameter(Mandatory)][string]$SourcePath,
        [Parameter(Mandatory)][string]$Pattern,
        [Parameter(Mandatory)][string]$Replacement,
        [Parameter(Mandatory)][string]$Name
    )

    $source = [System.IO.File]::ReadAllText($SourcePath)
    $regex = [regex]::new(
        $Pattern,
        [System.Text.RegularExpressions.RegexOptions]::Multiline
    )
    if ($regex.Matches($source).Count -ne 1) {
        throw "El marcador de inyección debe aparecer exactamente una vez: $SourcePath"
    }
    return Write-TemporarySql -Sql $regex.Replace($source, $Replacement, 1) -Name $Name
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
        [string]$ExpectedSqlState,
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
            if ($ExpectedSqlState -and $result.Text -notmatch ("(?m)\b{0}:" -f [regex]::Escape($ExpectedSqlState))) {
                throw "Expected failure for $Case did not contain SQLSTATE ${ExpectedSqlState}:`n$($result.Text)"
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
        [string]$ExpectedSqlState,
        [string]$ExpectedPattern
    )

    $path = Write-TemporarySql -Sql $Sql -Name (([guid]::NewGuid().ToString('N')) + '.sql')
    try {
        return Invoke-PsqlFile -Case $Case -Path $path -Database $Database -User $User -ExpectFailure:$ExpectFailure -ExpectedSqlState $ExpectedSqlState -ExpectedPattern $ExpectedPattern
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
        [string]$UserB = 'postgres',
        [string]$DatabaseA = 'iqg_runtime',
        [string]$DatabaseB = 'iqg_runtime',
        [scriptblock]$BeforeB
    )

    $taskA = Start-PsqlTask -Case ("{0}_A" -f $Label) -Path $PathA -Database $DatabaseA -User $UserA
    if ($null -ne $BeforeB) {
        & $BeforeB
    }
    else {
        Start-Sleep -Milliseconds 500
    }
    $watchB = [System.Diagnostics.Stopwatch]::StartNew()
    $taskB = Start-PsqlTask -Case ("{0}_B" -f $Label) -Path $PathB -Database $DatabaseB -User $UserB
    $resultB = Complete-PsqlTask -Task $taskB
    $watchB.Stop()
    $resultA = Complete-PsqlTask -Task $taskA
    return [pscustomobject]@{ A = $resultA; B = $resultB; BElapsedSeconds = $watchB.Elapsed.TotalSeconds }
}

function Wait-ForPhase0ClusterRoleLock {
    param([int]$TimeoutSeconds = 10)

    $deadline = [datetime]::UtcNow.AddSeconds($TimeoutSeconds)
    $sql = @'
SELECT CASE WHEN count(DISTINCT relation) = 2
            THEN 'PHASE0_CLUSTER_ROLE_LOCK_HELD'
            ELSE 'PHASE0_CLUSTER_ROLE_LOCK_WAITING'
       END
 FROM pg_locks
 WHERE locktype = 'relation'
   AND database = 0
   AND relation IN (
       'pg_catalog.pg_authid'::regclass,
       'pg_catalog.pg_auth_members'::regclass
   )
   AND mode = 'ShareRowExclusiveLock'
   AND granted;
'@

    while ([datetime]::UtcNow -lt $deadline) {
        $probe = Invoke-Engine -Arguments @(
            'exec', $script:ContainerName,
            'psql', '-X', '-tA', '-v', 'ON_ERROR_STOP=1',
            '-h', '127.0.0.1', '-U', 'postgres', '-d', 'postgres', '-c', $sql
        )
        if ($probe.Text.Trim() -eq 'PHASE0_CLUSTER_ROLE_LOCK_HELD') {
            return
        }
        Start-Sleep -Milliseconds 100
    }

    throw 'PHASE 0 no adquirió los locks de catálogos compartidos dentro del plazo de prueba.'
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
    if (-not (Test-Path -LiteralPath $BootstrapPath)) {
        throw "No existe el bootstrap de infraestructura esperado: $BootstrapPath"
    }
    if (-not (Test-Path -LiteralPath $SchemaPath)) {
        throw "No existe el DDL Phase 1 esperado: $SchemaPath"
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

    # BOOT-01: un instalador CREATEROLE no-superusuario debe fallar cerrado en
    # PHASE 0, antes de crear roles IQG persistentes.
    New-TestDatabase -Name 'iqg_phase0_nonpriv_probe'
    Invoke-PsqlFile -Case 'BOOT01_phase0_nonprivileged_rejected' -Path $BootstrapPath -Database 'iqg_phase0_nonpriv_probe' -User 'iqg_test_admin' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL carece de privilegios PostgreSQL 16 para establecer la topología segura' | Out-Null
    Invoke-PsqlFile -Case 'BOOT01_no_residual_iqg_state' -Path (Join-Path $SqlRoot 'bootstrap_absence_assertions.sql') -Database 'iqg_phase0_nonpriv_probe' | Out-Null

    # BOOT-08a: un error dentro de PHASE 0 revierte roles y cualquier estado
    # asociado. El marcador COMMIT debe existir una sola vez.
    New-TestDatabase -Name 'iqg_phase0_rollback_probe'
    $phase0RollbackPath = New-InjectedSql -SourcePath $BootstrapPath -Pattern '^COMMIT;\s*$' -Replacement ("SELECT 1 / 0;{0}COMMIT;" -f [Environment]::NewLine) -Name 'phase0_rollback_probe.sql'
    try {
        Invoke-PsqlFile -Case 'BOOT08_phase0_injected_failure' -Path $phase0RollbackPath -Database 'iqg_phase0_rollback_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState '22012' -ExpectedPattern 'division by zero' | Out-Null
    }
    finally {
        Remove-Item -LiteralPath $phase0RollbackPath -Force -ErrorAction SilentlyContinue
    }
    Invoke-PsqlFile -Case 'BOOT08_phase0_no_residual_iqg_state' -Path (Join-Path $SqlRoot 'bootstrap_absence_assertions.sql') -Database 'iqg_phase0_rollback_probe' | Out-Null

    # BOOT-08b/08c: fallos dentro del bloque de roles, después de endurecer
    # iqg_owner y después de normalizar memberships IQG, revierten el catálogo
    # global completo. Cada inyección usa un archivo temporal y una base nueva.
    New-TestDatabase -Name 'iqg_phase0_owner_rollback_probe'
    $phase0OwnerRollbackPath = New-InjectedSql -SourcePath $BootstrapPath -Pattern '^\s*-- PHASE 0_OWNER_ROLE_READY:.*$' -Replacement ("        -- PHASE 0_OWNER_ROLE_READY: prueba temporal{0}        PERFORM 1 / 0;" -f [Environment]::NewLine) -Name 'phase0_owner_rollback_probe.sql'
    try {
        Invoke-PsqlFile -Case 'BOOT08_phase0_owner_midway_failure' -Path $phase0OwnerRollbackPath -Database 'iqg_phase0_owner_rollback_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState '22012' -ExpectedPattern 'division by zero' | Out-Null
    }
    finally {
        Remove-Item -LiteralPath $phase0OwnerRollbackPath -Force -ErrorAction SilentlyContinue
    }
    Invoke-PsqlFile -Case 'BOOT08_phase0_owner_no_residual_iqg_state' -Path (Join-Path $SqlRoot 'bootstrap_absence_assertions.sql') -Database 'iqg_phase0_owner_rollback_probe' | Out-Null

    New-TestDatabase -Name 'iqg_phase0_membership_rollback_probe'
    $phase0MembershipRollbackPath = New-InjectedSql -SourcePath $BootstrapPath -Pattern '^\s*-- PHASE 0_KNOWN_MEMBERSHIPS_NORMALIZED:.*$' -Replacement ("        -- PHASE 0_KNOWN_MEMBERSHIPS_NORMALIZED: prueba temporal{0}        PERFORM 1 / 0;" -f [Environment]::NewLine) -Name 'phase0_membership_rollback_probe.sql'
    try {
        Invoke-PsqlFile -Case 'BOOT08_phase0_membership_midway_failure' -Path $phase0MembershipRollbackPath -Database 'iqg_phase0_membership_rollback_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState '22012' -ExpectedPattern 'division by zero' | Out-Null
    }
    finally {
        Remove-Item -LiteralPath $phase0MembershipRollbackPath -Force -ErrorAction SilentlyContinue
    }
    Invoke-PsqlFile -Case 'BOOT08_phase0_membership_no_residual_iqg_state' -Path (Join-Path $SqlRoot 'bootstrap_absence_assertions.sql') -Database 'iqg_phase0_membership_rollback_probe' | Out-Null

    # BOOT-02/03: dos ejecuciones PHASE 0 desde bases distintas deben quedar
    # serializadas por los catálogos compartidos. La primera copia se pausa
    # sólo en el artefacto temporal después de adquirir el lock; la segunda
    # debe esperar, completar y conservar la misma topología global segura.
    New-TestDatabase -Name 'iqg_phase0_concurrency_a'
    New-TestDatabase -Name 'iqg_phase0_concurrency_b'
    $phase0ConcurrencyPath = New-InjectedSql -SourcePath $BootstrapPath -Pattern '^\s*-- PHASE 0_CLUSTER_ROLE_LOCK_ACQUIRED:.*$' -Replacement ("        -- PHASE 0_CLUSTER_ROLE_LOCK_ACQUIRED: prueba temporal{0}        PERFORM pg_sleep(3);" -f [Environment]::NewLine) -Name 'phase0_cross_database_concurrency.sql'
    try {
        $phase0Pair = Invoke-ConcurrentPair -Label 'BOOT02_phase0_cross_database' `
            -PathA $phase0ConcurrencyPath `
            -PathB $BootstrapPath `
            -DatabaseA 'iqg_phase0_concurrency_a' `
            -DatabaseB 'iqg_phase0_concurrency_b' `
            -BeforeB { Wait-ForPhase0ClusterRoleLock }
    }
    finally {
        Remove-Item -LiteralPath $phase0ConcurrencyPath -Force -ErrorAction SilentlyContinue
    }
    Assert-TaskOutcome -Task $phase0Pair.A -ShouldSucceed $true
    Assert-TaskOutcome -Task $phase0Pair.B -ShouldSucceed $true
    if ($phase0Pair.BElapsedSeconds -lt 1.5) {
        throw "PHASE 0 en la segunda base no esperó el lock compartido: $($phase0Pair.BElapsedSeconds)s"
    }
    Invoke-PsqlFile -Case 'BOOT02_phase0_cross_database_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') -Database 'iqg_phase0_concurrency_a' | Out-Null

    # Una identidad insuficiente debe fallar también en PHASE 1 después de una
    # topología PHASE 0 válida. Aunque sea dueña de la base QA, no puede asumir
    # iqg_owner ni dejar schemas IQG residuales.
    New-TestDatabase -Name 'iqg_phase1_nonpriv_probe'
    Invoke-PsqlFile -Case 'BOOT01_phase1_nonprivileged_rejected' -Path $SchemaPath -Database 'iqg_phase1_nonpriv_probe' -User 'iqg_test_admin' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL no puede crear y asignar ownership de los schemas IQG' | Out-Null
    Invoke-PsqlFile -Case 'BOOT01_phase1_no_schema_residual' -Path (Join-Path $SqlRoot 'phase1_absence_assertions.sql') -Database 'iqg_phase1_nonpriv_probe' | Out-Null
    Invoke-PsqlFile -Case 'BOOT01_phase1_keeps_phase0_safe' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') -Database 'iqg_phase1_nonpriv_probe' | Out-Null

    # La precondición PHASE 1 de ZERO MEMBERS se prueba contra una topología
    # contaminada, antes de que el DDL tenga oportunidad de crear schemas.
    New-TestDatabase -Name 'iqg_phase1_owner_member_probe'
    Invoke-PsqlText -Case 'PHASE1_seed_owner_member_precondition' -Sql @'
CREATE ROLE qa_phase1_owner_member_probe NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
GRANT iqg_owner TO qa_phase1_owner_member_probe WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;
'@ | Out-Null
    try {
        Invoke-PsqlFile -Case 'PHASE1_owner_member_precondition_refused' -Path $SchemaPath -Database 'iqg_phase1_owner_member_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'PHASE 1 requiere iqg_owner con ZERO MEMBERS' | Out-Null
        Invoke-PsqlFile -Case 'PHASE1_owner_member_no_schema_residual' -Path (Join-Path $SqlRoot 'phase1_absence_assertions.sql') -Database 'iqg_phase1_owner_member_probe' | Out-Null
        Invoke-PsqlText -Case 'PHASE1_owner_member_preserved_on_failure' -Sql @'
DO $assert_phase1_owner_member$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE roleid = 'iqg_owner'::regrole
           AND member = 'qa_phase1_owner_member_probe'::regrole
    ) THEN
        RAISE EXCEPTION 'PHASE 1 reparó silenciosamente un miembro accidental de iqg_owner';
    END IF;
END;
$assert_phase1_owner_member$;
'@ | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'PHASE1_cleanup_owner_member_precondition' -Sql @'
REVOKE iqg_owner FROM qa_phase1_owner_member_probe;
DROP ROLE qa_phase1_owner_member_probe;
'@ | Out-Null
    }
    Invoke-PsqlFile -Case 'PHASE1_owner_member_topology_after_cleanup' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') -Database 'iqg_phase1_owner_member_probe' | Out-Null

    # PHASE 1 puede normalizar el ownership de schemas realmente vacíos. Esta
    # es la única forma de schema preexistente que el instalador acepta.
    New-TestDatabase -Name 'iqg_phase1_wrong_owner_probe'
    Invoke-PsqlText -Case 'PHASE1_seed_empty_wrong_owner_schemas' -Database 'iqg_phase1_wrong_owner_probe' -User 'iqg_test_admin' -Sql @'
CREATE SCHEMA iqg_core AUTHORIZATION iqg_test_admin;
CREATE SCHEMA iqg_fiscal AUTHORIZATION iqg_test_admin;
'@ | Out-Null
    Invoke-PsqlFile -Case 'PHASE1_empty_wrong_owner_normalized' -Path $SchemaPath -Database 'iqg_phase1_wrong_owner_probe' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'PHASE1_empty_wrong_owner_catalog' -Path (Join-Path $SqlRoot 'phase1_catalog_assertions.sql') -Database 'iqg_phase1_wrong_owner_probe' | Out-Null

    # Un schema vacío con ACL explícita no es seguro de absorber: ALTER OWNER
    # no elimina el grant del dueño anterior. Se prueba rollback sin mutarlo.
    New-TestDatabase -Name 'iqg_phase1_schema_acl_probe'
    Invoke-PsqlText -Case 'PHASE1_create_schema_acl_probe_role' -Sql @'
CREATE ROLE qa_schema_acl_probe NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
'@ | Out-Null
    try {
        Invoke-PsqlText -Case 'PHASE1_seed_explicit_schema_acl' -Database 'iqg_phase1_schema_acl_probe' -User 'iqg_test_admin' -Sql @'
CREATE SCHEMA iqg_core AUTHORIZATION iqg_test_admin;
CREATE SCHEMA iqg_fiscal AUTHORIZATION iqg_test_admin;
GRANT USAGE ON SCHEMA iqg_core TO qa_schema_acl_probe;
'@ | Out-Null
        Invoke-PsqlFile -Case 'PHASE1_explicit_schema_acl_refused' -Path $SchemaPath -Database 'iqg_phase1_schema_acl_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'PHASE1_UNSAFE_EXISTING_SCHEMA_STATE: iqg_core o iqg_fiscal existente contiene ACL, default ACL u objetos; se requiere una migración revisada' | Out-Null
        Invoke-PsqlText -Case 'PHASE1_explicit_schema_acl_preserved_on_failure' -Database 'iqg_phase1_schema_acl_probe' -Sql @'
DO $assert_phase1_schema_acl$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_namespace
         WHERE nspname = 'iqg_core' AND nspowner = 'iqg_test_admin'::regrole
    ) OR NOT has_schema_privilege('qa_schema_acl_probe', 'iqg_core', 'USAGE') THEN
        RAISE EXCEPTION 'PHASE 1 alteró el fixture de ACL hostil durante el fallo';
    END IF;
END;
$assert_phase1_schema_acl$;
'@ | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'PHASE1_cleanup_schema_acl_probe' -Database 'iqg_phase1_schema_acl_probe' -Sql @'
REVOKE ALL ON SCHEMA iqg_core FROM qa_schema_acl_probe;
DROP ROLE qa_schema_acl_probe;
'@ | Out-Null
    }

    # Un objeto preexistente también se rechaza antes del cambio de owner. La
    # aserción verifica que el objeto y el owner de prueba no fueron absorbidos.
    New-TestDatabase -Name 'iqg_phase1_schema_object_probe'
    Invoke-PsqlText -Case 'PHASE1_seed_existing_schema_object' -Database 'iqg_phase1_schema_object_probe' -User 'iqg_test_admin' -Sql @'
CREATE SCHEMA iqg_core AUTHORIZATION iqg_test_admin;
CREATE SCHEMA iqg_fiscal AUTHORIZATION iqg_test_admin;
CREATE TABLE iqg_core.qa_preexisting_object (id integer PRIMARY KEY);
'@ | Out-Null
    Invoke-PsqlFile -Case 'PHASE1_existing_schema_object_refused' -Path $SchemaPath -Database 'iqg_phase1_schema_object_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'PHASE1_UNSAFE_EXISTING_SCHEMA_STATE: iqg_core o iqg_fiscal existente contiene ACL, default ACL u objetos; se requiere una migración revisada' | Out-Null
    Invoke-PsqlText -Case 'PHASE1_existing_schema_object_preserved_on_failure' -Database 'iqg_phase1_schema_object_probe' -Sql @'
DO $assert_phase1_schema_object$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_namespace
         WHERE nspname = 'iqg_core' AND nspowner = 'iqg_test_admin'::regrole
    ) OR to_regclass('iqg_core.qa_preexisting_object') IS NULL THEN
        RAISE EXCEPTION 'PHASE 1 alteró el fixture de objeto hostil durante el fallo';
    END IF;
END;
$assert_phase1_schema_object$;
'@ | Out-Null

    # Un default ACL global del owner afecta objetos futuros de ambos schemas y
    # por eso debe causar rechazo antes de crear cualquier objeto del Core.
    New-TestDatabase -Name 'iqg_phase1_default_acl_probe'
    Invoke-PsqlText -Case 'PHASE1_create_default_acl_probe_role' -Sql @'
CREATE ROLE qa_default_acl_probe NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
'@ | Out-Null
    try {
        Invoke-PsqlText -Case 'PHASE1_seed_global_owner_default_acl' -Database 'iqg_phase1_default_acl_probe' -Sql @'
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner
    GRANT EXECUTE ON FUNCTIONS TO qa_default_acl_probe;
'@ | Out-Null
        Invoke-PsqlFile -Case 'PHASE1_global_owner_default_acl_refused' -Path $SchemaPath -Database 'iqg_phase1_default_acl_probe' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'PHASE1_UNSAFE_EXISTING_SCHEMA_STATE: iqg_owner conserva default ACL previo; se requiere una migración revisada' | Out-Null
        Invoke-PsqlFile -Case 'PHASE1_global_owner_default_acl_no_schema_residual' -Path (Join-Path $SqlRoot 'phase1_absence_assertions.sql') -Database 'iqg_phase1_default_acl_probe' | Out-Null
        Invoke-PsqlText -Case 'PHASE1_global_owner_default_acl_preserved_on_failure' -Database 'iqg_phase1_default_acl_probe' -Sql @'
DO $assert_phase1_default_acl$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_default_acl AS default_acl
         CROSS JOIN LATERAL aclexplode(default_acl.defaclacl) AS acl
         WHERE default_acl.defaclrole = 'iqg_owner'::regrole
           AND default_acl.defaclnamespace = 0
           AND default_acl.defaclobjtype = 'f'
           AND acl.grantee = 'qa_default_acl_probe'::regrole
           AND acl.privilege_type = 'EXECUTE'
    ) THEN
        RAISE EXCEPTION 'PHASE 1 alteró el fixture de default ACL hostil durante el fallo';
    END IF;
END;
$assert_phase1_default_acl$;
'@ | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'PHASE1_cleanup_default_acl_probe' -Database 'iqg_phase1_default_acl_probe' -Sql @'
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner
    REVOKE EXECUTE ON FUNCTIONS FROM qa_default_acl_probe;
DROP ROLE qa_default_acl_probe;
'@ | Out-Null
    }

    # Se prepara una base independiente para PHASE 1. `postgres` es sólo la
    # implementación efímera del concepto PRIVILEGED_BOOTSTRAP_PRINCIPAL.
    New-TestDatabase -Name 'iqg_runtime'
    Invoke-PsqlFile -Case 'A_phase0_runtime_reexecution' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'A_phase0_runtime_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # BOOT-02: el principal privilegiado no puede conservar membership de
    # runtime. PHASE 0 rechaza el drift y el arnés prueba que no lo oculta.
    Invoke-PsqlText -Case 'BOOT02_seed_privileged_principal_membership' -Sql @'
GRANT iqg_app TO postgres WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;
'@ | Out-Null
    try {
        Invoke-PsqlFile -Case 'BOOT02_privileged_principal_membership_refused' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL conserva una membership IQG' | Out-Null
        Invoke-PsqlText -Case 'BOOT02_privileged_principal_membership_preserved_on_failure' -Sql @'
DO $assert_boot02_failure_state$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE roleid = 'iqg_app'::regrole
           AND member = 'postgres'::regrole
    ) THEN
        RAISE EXCEPTION 'BOOT-02: PHASE 0 reparó silenciosamente la membership del principal privilegiado';
    END IF;
END;
$assert_boot02_failure_state$;
'@ | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'BOOT02_cleanup_privileged_principal_membership' -Sql @'
REVOKE iqg_app FROM postgres;
'@ | Out-Null
    }
    Invoke-PsqlFile -Case 'BOOT02_topology_after_explicit_remediation' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # BOOT-09: atributos inseguros de un iqg_owner ya existente se corrigen en
    # una reejecución idempotente sin concederle roles ni membresías nuevas.
    Invoke-PsqlText -Case 'BOOT09_seed_owner_attribute_drift' -Sql @'
ALTER ROLE iqg_owner LOGIN BYPASSRLS;
'@ | Out-Null
    Invoke-PsqlFile -Case 'BOOT09_owner_attribute_drift_corrected' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'BOOT09_owner_attribute_drift_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # BOOT-03: un miembro accidental de iqg_owner es distinto de que el owner
    # sea miembro de otro rol. Ambos sentidos deben fallar cerrado y preservar
    # la evidencia hasta una remediación explícita.
    Invoke-PsqlText -Case 'BOOT03_seed_owner_member_probe' -Sql @'
CREATE ROLE qa_owner_member_probe NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
GRANT iqg_owner TO qa_owner_member_probe WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;
'@ | Out-Null
    try {
        Invoke-PsqlFile -Case 'BOOT03_owner_member_refused' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'iqg_owner debe terminar PHASE 0 con ZERO MEMBERS' | Out-Null
        Invoke-PsqlText -Case 'BOOT03_owner_member_preserved_on_failure' -Sql @'
DO $assert_boot03_owner_member$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE roleid = 'iqg_owner'::regrole
           AND member = 'qa_owner_member_probe'::regrole
    ) THEN
        RAISE EXCEPTION 'BOOT-03: PHASE 0 reparó silenciosamente un miembro accidental de iqg_owner';
    END IF;
END;
$assert_boot03_owner_member$;
'@ | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'BOOT03_cleanup_owner_member_probe' -Sql @'
REVOKE iqg_owner FROM qa_owner_member_probe;
DROP ROLE qa_owner_member_probe;
'@ | Out-Null
    }
    Invoke-PsqlFile -Case 'BOOT03_owner_member_recovery' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'BOOT03_owner_member_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # BOOT-09: iqg_app no puede heredar un rol externo. PHASE 0 debe rechazar
    # el estado en vez de revocar una relación que pertenezca a otro servicio.
    Invoke-PsqlText -Case 'BOOT09_seed_app_external_parent' -Sql @'
CREATE ROLE qa_app_parent_probe NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
GRANT qa_app_parent_probe TO iqg_app WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;
'@ | Out-Null
    try {
        Invoke-PsqlFile -Case 'BOOT09_app_external_parent_refused' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: un rol IQG ya pertenece a otro rol' | Out-Null
        Invoke-PsqlText -Case 'BOOT09_app_external_parent_preserved_on_failure' -Sql @'
DO $assert_boot09_app_parent$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE roleid = 'qa_app_parent_probe'::regrole
           AND member = 'iqg_app'::regrole
    ) THEN
        RAISE EXCEPTION 'BOOT-09: PHASE 0 reparó silenciosamente la membership externa de iqg_app';
    END IF;
END;
$assert_boot09_app_parent$;
'@ | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'BOOT09_cleanup_app_external_parent' -Sql @'
REVOKE qa_app_parent_probe FROM iqg_app;
DROP ROLE qa_app_parent_probe;
'@ | Out-Null
    }
    Invoke-PsqlFile -Case 'BOOT09_app_external_parent_recovery' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'BOOT09_app_external_parent_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # Un bootstrap no debe revocar una membership externa desconocida por
    # intuición. Se demuestra que la detecta, falla cerrado y requiere limpieza
    # explícita dentro del clúster QA antes de continuar.
    Invoke-PsqlText -Case 'BOOT03_create_external_membership_probe' -Sql @'
CREATE ROLE qa_external_membership_probe NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
GRANT qa_external_membership_probe TO iqg_owner WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;
'@ | Out-Null
    try {
        Invoke-PsqlFile -Case 'BOOT03_external_membership_refused' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: un rol IQG ya pertenece a otro rol' | Out-Null
    }
    finally {
        Invoke-PsqlText -Case 'BOOT03_cleanup_external_membership_probe' -Sql @'
REVOKE qa_external_membership_probe FROM iqg_owner;
DROP ROLE qa_external_membership_probe;
'@ | Out-Null
    }
    Invoke-PsqlFile -Case 'BOOT03_topology_after_explicit_remediation' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # BOOT-08b: PHASE 1 falla tras crear/asignar schemas pero antes del DDL de
    # objetos. La transacción revierte schemas; PHASE 0 permanece segura.
    $phase1RollbackPath = New-InjectedSql -SourcePath $SchemaPath -Pattern '^-- PHASE 1_OBJECT_DDL_START:.*$' -Replacement ("SELECT 1 / 0;{0}-- PHASE 1_OBJECT_DDL_START:" -f [Environment]::NewLine) -Name 'phase1_rollback_probe.sql'
    try {
        Invoke-PsqlFile -Case 'BOOT08_phase1_injected_failure' -Path $phase1RollbackPath -Database 'iqg_runtime' -User 'postgres' -ExpectFailure -ExpectedSqlState '22012' -ExpectedPattern 'division by zero' | Out-Null
    }
    finally {
        Remove-Item -LiteralPath $phase1RollbackPath -Force -ErrorAction SilentlyContinue
    }
    Invoke-PsqlFile -Case 'BOOT08_phase1_no_schema_residual' -Path (Join-Path $SqlRoot 'phase1_absence_assertions.sql') | Out-Null
    Invoke-PsqlFile -Case 'BOOT08_phase1_keeps_phase0_safe' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # BOOT-08e: un fallo después de todo el DDL, revocaciones, default ACL,
    # GRANT estrecho y verificaciones finales aún debe revertir ambos schemas.
    $phase1FinalRollbackPath = New-InjectedSql -SourcePath $SchemaPath -Pattern '^-- PHASE 1_FINAL_SECURITY_POSTURE_VERIFIED:.*$' -Replacement ("SELECT 1 / 0;{0}-- PHASE 1_FINAL_SECURITY_POSTURE_VERIFIED:" -f [Environment]::NewLine) -Name 'phase1_final_rollback_probe.sql'
    try {
        Invoke-PsqlFile -Case 'BOOT08_phase1_final_injected_failure' -Path $phase1FinalRollbackPath -Database 'iqg_runtime' -User 'postgres' -ExpectFailure -ExpectedSqlState '22012' -ExpectedPattern 'division by zero' | Out-Null
    }
    finally {
        Remove-Item -LiteralPath $phase1FinalRollbackPath -Force -ErrorAction SilentlyContinue
    }
    Invoke-PsqlFile -Case 'BOOT08_phase1_final_no_schema_residual' -Path (Join-Path $SqlRoot 'phase1_absence_assertions.sql') | Out-Null
    Invoke-PsqlFile -Case 'BOOT08_phase1_final_keeps_phase0_safe' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null

    # Recovery demostrada: se reejecuta únicamente PHASE 1 sobre la topology
    # segura ya existente; no se presenta como migración in-place poblada.
    Invoke-PsqlFile -Case 'A_clean_phase1_recovery' -Path $SchemaPath -Database 'iqg_runtime' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'A_phase1_catalog' -Path (Join-Path $SqlRoot 'phase1_catalog_assertions.sql') | Out-Null
    Invoke-PsqlFile -Case 'A_postinstall_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null
    Write-MatrixPass -Id 'A' -Detail 'PHASE 0 y PHASE 1 instalan el Core con owner sin miembros'
    Write-MatrixPass -Id 'B' -Detail 'fallos inyectados revierten PHASE 0 y PHASE 1 dentro de sus límites transaccionales'

    # BOOT-09: la segunda PHASE 0 no deriva roles, ACL ni la postura del Core.
    Invoke-PsqlFile -Case 'BOOT09_phase0_second_execution' -Path $BootstrapPath -Database 'iqg_runtime' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'BOOT09_topology_still_safe' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') | Out-Null
    Invoke-PsqlFile -Case 'BOOT09_phase1_catalog_unchanged' -Path (Join-Path $SqlRoot 'phase1_catalog_assertions.sql') | Out-Null

    Invoke-PsqlFile -Case 'QA_support' -Path (Join-Path $SqlRoot '00_test_support.sql') | Out-Null
    Invoke-PsqlFile -Case 'BOOT04_app_cannot_set_owner' -Path (Join-Path $SqlRoot 'negative/app_cannot_set_owner.sql') -User 'qa_app_probe' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied to set role "iqg_owner"' | Out-Null
    Invoke-PsqlFile -Case 'C_app_direct_access_denied' -Path (Join-Path $SqlRoot 'negative/app_direct_access.sql') -User 'qa_app_probe' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied for schema iqg_core' | Out-Null
    Invoke-PsqlFile -Case 'BOOT05_gateway_cannot_set_owner' -Path (Join-Path $SqlRoot 'negative/gateway_cannot_set_owner.sql') -User 'qa_gateway_probe' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied to set role "iqg_owner"' | Out-Null
    Invoke-PsqlFile -Case 'C_gateway_direct_access_denied' -Path (Join-Path $SqlRoot 'negative/gateway_direct_access.sql') -User 'qa_gateway_probe' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied for schema iqg_core' | Out-Null
    Invoke-PsqlFile -Case 'BOOT06_bootstrap_cannot_set_owner' -Path (Join-Path $SqlRoot 'negative/bootstrap_cannot_set_owner.sql') -User 'qa_bootstrap' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied to set role "iqg_owner"' | Out-Null
    Invoke-PsqlFile -Case 'E_authorized_bootstrap' -Path (Join-Path $SqlRoot '01_bootstrap_positive.sql') -User 'qa_bootstrap' | Out-Null
    Invoke-PsqlFile -Case 'E_forged_guc_rejected' -Path (Join-Path $SqlRoot 'negative/untrusted_bootstrap_guc.sql') -User 'qa_untrusted' | Out-Null
    Invoke-PsqlFile -Case 'BOOT07_forged_guc_cannot_call_provisioning' -Path (Join-Path $SqlRoot 'negative/untrusted_bootstrap_endpoint.sql') -User 'qa_untrusted' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied for function provisionar_empresa' | Out-Null
    Invoke-PsqlFile -Case 'E_direct_bootstrap_table_denied' -Path (Join-Path $SqlRoot 'negative/bootstrap_direct_table.sql') -User 'qa_bootstrap' -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'permission denied for table empresa' | Out-Null
    Write-MatrixPass -Id 'E' -Detail 'bootstrap autorizado exige session_user; GUC falsificado no eleva endpoint ni tabla'

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

    Invoke-PsqlFile -Case 'I_cross_scope_write_denied' -Path (Join-Path $SqlRoot 'negative/cross_scope_write.sql') -ExpectFailure -ExpectedSqlState '42501' -ExpectedPattern 'row-level security policy' | Out-Null
    Write-MatrixPass -Id 'I' -Detail 'escritura cross-company/cross-branch se rechaza'
    Invoke-PsqlFile -Case 'N_bad_operacion_line_unit_denied' -Path (Join-Path $SqlRoot 'negative/bad_operacion_line_unit.sql') -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'La unidad de medida de una línea debe coincidir con la unidad base del elemento' | Out-Null
    Write-MatrixPass -Id 'N' -Detail 'unidad incompatible de línea de operación se rechaza'
    Invoke-PsqlFile -Case 'R_price_append_only' -Path (Join-Path $SqlRoot 'negative/append_only_price.sql') -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'precio_vigente es append-only' | Out-Null
    Invoke-PsqlFile -Case 'R_audit_immutable' -Path (Join-Path $SqlRoot 'negative/audit_mutation.sql') -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'registro_cambios solo permite una redacción legal controlada de datos de cliente' | Out-Null
    Invoke-PsqlFile -Case 'T_factura_without_lines_denied' -Path (Join-Path $SqlRoot 'negative/invalid_factura_without_lines.sql') -ExpectFailure -ExpectedSqlState 'P0001' -ExpectedPattern 'Las líneas de la factura deben existir y cuadrar exactamente con sus importes de cabecera' | Out-Null

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

    # W/BOOT-10: pg_dump/pg_restore es por base de datos y no restaura roles
    # globales. Se verifica la topology global después de restore y, por
    # separado, ownership/RLS/ACL de los objetos restaurados.
    $backupPath = '/tmp/iqg-runtime.dump'
    Invoke-Engine -Arguments @('exec', $script:ContainerName, 'pg_dump', '-Fc', '-h', '127.0.0.1', '-U', 'postgres', '-d', 'iqg_runtime', '-f', $backupPath) | Out-Null
    New-TestDatabase -Name 'iqg_restore_probe'
    Invoke-Engine -Arguments @('exec', $script:ContainerName, 'pg_restore', '-h', '127.0.0.1', '-U', 'postgres', '-d', 'iqg_restore_probe', $backupPath) | Out-Null
    Invoke-PsqlFile -Case 'BOOT10_restore_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') -Database 'iqg_restore_probe' | Out-Null
    Invoke-PsqlFile -Case 'BOOT10_restore_catalog' -Path (Join-Path $SqlRoot 'phase1_catalog_assertions.sql') -Database 'iqg_restore_probe' | Out-Null
    Invoke-PsqlFile -Case 'W_restore_assertions' -Path (Join-Path $SqlRoot 'restore_assertions.sql') -Database 'iqg_restore_probe' | Out-Null
    New-TestDatabase -Name 'iqg_reexecution_probe'
    # La nueva base recibe ambas fases. PHASE 1 no se presenta como una
    # migración reejecutable sobre una base poblada.
    Invoke-PsqlFile -Case 'W_phase0_clean_reexecution' -Path $BootstrapPath -Database 'iqg_reexecution_probe' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'W_phase0_topology' -Path (Join-Path $SqlRoot 'bootstrap_topology_assertions.sql') -Database 'iqg_reexecution_probe' | Out-Null
    Invoke-PsqlFile -Case 'W_phase1_clean_reexecution' -Path $SchemaPath -Database 'iqg_reexecution_probe' -User 'postgres' | Out-Null
    Invoke-PsqlFile -Case 'W_phase1_catalog' -Path (Join-Path $SqlRoot 'phase1_catalog_assertions.sql') -Database 'iqg_reexecution_probe' | Out-Null
    Write-MatrixPass -Id 'W' -Detail 'dump/restore conserva topology/ACL y nueva instalación ejecuta ambas fases'

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
