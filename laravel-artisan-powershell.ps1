# Laravel Artisan Helper for PowerShell
# Created by: Kaushalya 😎
# Add this to your PowerShell Profile
# ==============================================================

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

# ==============================================================
# ARTISAN COMMAND SHORTCUTS (Functions)
# ==============================================================

# Basic Commands
function pa { php artisan @args }
function pah { php artisan help @args }
function pal { php artisan list @args }
function pav { php artisan --version }

# Server & Setup
function pas { php artisan serve @args }
function paserve { php artisan serve --host=0.0.0.0 --port=8000 @args }

# Database Operations
function pam { php artisan migrate @args }
function pamf { php artisan migrate:fresh @args }
function pamfs { php artisan migrate:fresh --seed @args }
function pamr { php artisan migrate:rollback @args }
function pams { php artisan migrate --seed @args }
function pads { php artisan db:seed @args }

# Code Generation
function pamk { php artisan make: @args }
function pamkm { php artisan make:model @args }
function pamkc { php artisan make:controller @args }
function pamkmi { php artisan make:migration @args }
function pamks { php artisan make:seeder @args }
function pamkf { php artisan make:factory @args }
function pamkp { php artisan make:policy @args }
function pamkmd { php artisan make:middleware @args }
function pamkt { php artisan make:test @args }

# Routing
function par { php artisan route:list @args }
function parc { php artisan route:cache }
function parcl { php artisan route:clear }

# Cache Operations
function pac { php artisan cache:clear }
function pacc { php artisan config:cache }
function paccl { php artisan config:clear }
function pavc { php artisan view:cache }
function pavcl { php artisan view:clear }
function paec { php artisan event:cache }
function paecl { php artisan event:clear }
function paoc { php artisan optimize:clear }
function paopt { php artisan optimize }

# Development Tools
function pat { php artisan tinker @args }
function patest { php artisan test @args }
function paq { php artisan queue:work @args }
function paql { php artisan queue:listen @args }
function paqr { php artisan queue:restart }

# Maintenance
function pad { php artisan down @args }
function pau { php artisan up }

# Storage & Links
function pasl { php artisan storage:link }

# Authentication
function pakg { php artisan key:generate }

# Combined Operations
function paclear {
    Write-Host "🧹 Clearing all caches..." -ForegroundColor $Colors.Yellow
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    Write-Host "✅ All caches cleared!" -ForegroundColor $Colors.Green
}

function pacache {
    Write-Host "⚡ Caching for performance..." -ForegroundColor $Colors.Yellow
    php artisan route:cache
    php artisan config:cache
    php artisan view:cache
    Write-Host "✅ Caching completed!" -ForegroundColor $Colors.Green
}

function paoptimize {
    Write-Host "🚀 Optimizing application..." -ForegroundColor $Colors.Yellow
    php artisan optimize
    php artisan route:cache
    php artisan config:cache
    php artisan view:cache
    Write-Host "✅ Optimization completed!" -ForegroundColor $Colors.Green
}

# ==============================================================
# ENHANCED FUNCTIONS
# ==============================================================

# Quick model creation with migration and controller
function pamkall {
    param([string]$ModelName)
    
    if (-not $ModelName) {
        Write-Host "❌ Usage: pamkall ModelName" -ForegroundColor $Colors.Red
        return
    }
    
    Write-Host "🔨 Creating Model, Migration, Controller, and Factory for: $ModelName" -ForegroundColor $Colors.Yellow
    php artisan make:model $ModelName -mcf
    Write-Host "✅ Created: Model, Migration, Controller, and Factory for $ModelName" -ForegroundColor $Colors.Green
}

# Quick project setup
function pasetup {
    Write-Host "🚀 Setting up Laravel project..." -ForegroundColor $Colors.Yellow
    php artisan key:generate
    php artisan storage:link
    php artisan migrate
    Write-Host "✅ Project setup completed!" -ForegroundColor $Colors.Green
}

# Development server with custom host/port
function padev {
    param(
        [string]$Host = "127.0.0.1",
        [int]$Port = 8000
    )
    
    Write-Host "🌐 Starting Laravel development server on http://$Host`:$Port" -ForegroundColor $Colors.Blue
    php artisan serve --host=$Host --port=$Port
}

# Fresh installation
function pafresh {
    Write-Host "🔄 Fresh installation starting..." -ForegroundColor $Colors.Yellow
    php artisan migrate:fresh --seed
    php artisan storage:link
    php artisan optimize:clear
    Write-Host "✅ Fresh installation completed!" -ForegroundColor $Colors.Green
}

# Production optimization
function paprod {
    Write-Host "⚡ Optimizing for production..." -ForegroundColor $Colors.Yellow
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan event:cache
    php artisan optimize
    Write-Host "✅ Production optimization completed!" -ForegroundColor $Colors.Green
}

# Show Laravel info
function painfo {
    Write-Host "📋 Laravel Project Information:" -ForegroundColor $Colors.Blue
    Write-Host "Laravel Version: $(php artisan --version)" -ForegroundColor $Colors.White
    Write-Host "PHP Version: $(php -v | Select-Object -First 1)" -ForegroundColor $Colors.White
    Write-Host "Project Path: $(Get-Location)" -ForegroundColor $Colors.White
    
    if (Test-Path ".env") {
        $env = (Get-Content ".env" | Where-Object { $_ -match "APP_ENV=" }) -replace "APP_ENV=", ""
        Write-Host "Environment: $env" -ForegroundColor $Colors.Yellow
    } else {
        Write-Host "Environment: .env not found" -ForegroundColor $Colors.Red
    }
}

# ==============================================================
# HELP FUNCTION
# ==============================================================

function pahelp {
    Write-Host "🔧 Laravel Artisan Helper - Available Shortcuts:" -ForegroundColor $Colors.Blue
    Write-Host ""
    Write-Host "Basic Commands:" -ForegroundColor $Colors.Yellow
    Write-Host "  pa          - php artisan"
    Write-Host "  pas         - php artisan serve"
    Write-Host "  pat         - php artisan tinker"
    Write-Host "  patest      - php artisan test"
    Write-Host ""
    Write-Host "Database:" -ForegroundColor $Colors.Yellow
    Write-Host "  pam         - php artisan migrate"
    Write-Host "  pamf        - php artisan migrate:fresh"
    Write-Host "  pamfs       - php artisan migrate:fresh --seed"
    Write-Host "  pads        - php artisan db:seed"
    Write-Host ""
    Write-Host "Code Generation:" -ForegroundColor $Colors.Yellow
    Write-Host "  pamkm       - php artisan make:model"
    Write-Host "  pamkc       - php artisan make:controller"
    Write-Host "  pamkmi      - php artisan make:migration"
    Write-Host "  pamkall     - Create model + migration + controller + factory"
    Write-Host ""
    Write-Host "Cache & Optimization:" -ForegroundColor $Colors.Yellow
    Write-Host "  pac         - php artisan cache:clear"
    Write-Host "  paclear     - Clear all caches"
    Write-Host "  pacache     - Cache routes, config, views"
    Write-Host "  paoptimize  - Full production optimization"
    Write-Host ""
    Write-Host "Custom Functions:" -ForegroundColor $Colors.Yellow
    Write-Host "  pasetup     - Quick project setup"
    Write-Host "  pafresh     - Fresh installation"
    Write-Host "  paprod      - Production optimization"
    Write-Host "  painfo      - Show Laravel info"
    Write-Host "  padev       - Development server with custom host/port"
    Write-Host ""
    Write-Host "💡 Tip: Use tab completion for better experience!" -ForegroundColor $Colors.Green
}

# ==============================================================
# TAB COMPLETION SETUP
# ==============================================================

# Register argument completers for main functions
$ArtisanCommands = @(
    'serve', 'migrate', 'migrate:fresh', 'migrate:rollback', 'migrate:reset',
    'make:model', 'make:controller', 'make:migration', 'make:seeder', 'make:factory',
    'make:middleware', 'make:policy', 'make:test', 'make:command',
    'route:list', 'route:cache', 'route:clear',
    'cache:clear', 'config:cache', 'config:clear',
    'view:cache', 'view:clear', 'event:cache', 'event:clear',
    'optimize', 'optimize:clear', 'tinker', 'test',
    'queue:work', 'queue:listen', 'queue:restart',
    'db:seed', 'storage:link', 'key:generate',
    'down', 'up', 'list', 'help', '--version'
)

Register-ArgumentCompleter -CommandName 'pa' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $ArtisanCommands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# ==============================================================
# INITIALIZATION MESSAGE
# ==============================================================

Write-Host "✅ Laravel Artisan Helper loaded successfully!" -ForegroundColor $Colors.Green
Write-Host "📚 Type 'pahelp' to see all available shortcuts" -ForegroundColor $Colors.Blue
Write-Host "🚀 Happy coding with Laravel! 😎" -ForegroundColor $Colors.Yellow