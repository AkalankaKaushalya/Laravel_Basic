#!/bin/bash
# Laravel Artisan Helper with Shortcuts & Auto-completion
# Created by: Kaushalya 😎
# Usage: source laravel-artisan.sh or add to ~/.bashrc or ~/.zshrc
# ==============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================
# ARTISAN COMMAND SHORTCUTS
# ==============================================================

# Basic Commands
alias pa="php artisan"
alias pah="php artisan help"
alias pal="php artisan list"
alias pav="php artisan --version"

# Server & Setup
alias pas="php artisan serve"
alias paserve="php artisan serve --host=0.0.0.0 --port=8000"

# Database Operations
alias pam="php artisan migrate"
alias pamf="php artisan migrate:fresh"
alias pamfs="php artisan migrate:fresh --seed"
alias pamr="php artisan migrate:rollback"
alias pams="php artisan migrate --seed"
alias pads="php artisan db:seed"

# Code Generation
alias pamk="php artisan make:"
alias pamkm="php artisan make:model"
alias pamkc="php artisan make:controller"
alias pamkmi="php artisan make:migration"
alias pamks="php artisan make:seeder"
alias pamkf="php artisan make:factory"
alias pamkp="php artisan make:policy"
alias pamkmd="php artisan make:middleware"
alias pamkt="php artisan make:test"

# Routing
alias par="php artisan route:list"
alias parc="php artisan route:cache"
alias parcl="php artisan route:clear"

# Cache Operations
alias pac="php artisan cache:clear"
alias pacc="php artisan config:cache"
alias paccl="php artisan config:clear"
alias pavc="php artisan view:cache"
alias pavcl="php artisan view:clear"
alias paec="php artisan event:cache"
alias paecl="php artisan event:clear"
alias paoc="php artisan optimize:clear"
alias paopt="php artisan optimize"

# Development Tools
alias pat="php artisan tinker"
alias patest="php artisan test"
alias paq="php artisan queue:work"
alias paql="php artisan queue:listen"
alias paqr="php artisan queue:restart"

# Maintenance
alias pad="php artisan down"
alias pau="php artisan up"

# Storage & Links
alias pasl="php artisan storage:link"

# Authentication
alias pakg="php artisan key:generate"

# Combined Operations
alias paclear="php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan view:clear"
alias pacache="php artisan route:cache && php artisan config:cache && php artisan view:cache"
alias paoptimize="php artisan optimize && php artisan route:cache && php artisan config:cache && php artisan view:cache"

# ==============================================================
# ENHANCED FUNCTIONS
# ==============================================================

# Quick model creation with migration and controller
pamkall() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: pamkall ModelName${NC}"
        return 1
    fi
    echo -e "${YELLOW}Creating Model, Migration, Controller, and Factory for: $1${NC}"
    php artisan make:model "$1" -mcf
    echo -e "${GREEN}✅ Created: Model, Migration, Controller, and Factory for $1${NC}"
}

# Quick project setup
pasetup() {
    echo -e "${YELLOW}🚀 Setting up Laravel project...${NC}"
    php artisan key:generate
    php artisan storage:link
    php artisan migrate
    echo -e "${GREEN}✅ Project setup completed!${NC}"
}

# Development server with custom host/port
padev() {
    local host=${1:-127.0.0.1}
    local port=${2:-8000}
    echo -e "${BLUE}🌐 Starting Laravel development server on http://$host:$port${NC}"
    php artisan serve --host="$host" --port="$port"
}

# Fresh installation
pafresh() {
    echo -e "${YELLOW}🔄 Fresh installation starting...${NC}"
    php artisan migrate:fresh --seed
    php artisan storage:link
    php artisan optimize:clear
    echo -e "${GREEN}✅ Fresh installation completed!${NC}"
}

# Production optimization
paprod() {
    echo -e "${YELLOW}⚡ Optimizing for production...${NC}"
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan event:cache
    php artisan optimize
    echo -e "${GREEN}✅ Production optimization completed!${NC}"
}

# Show Laravel info
painfo() {
    echo -e "${BLUE}📋 Laravel Project Information:${NC}"
    echo "Laravel Version: $(php artisan --version)"
    echo "PHP Version: $(php -v | head -n1)"
    echo "Project Path: $(pwd)"
    echo -e "${YELLOW}Environment: $(grep APP_ENV .env 2>/dev/null | cut -d '=' -f2 || echo 'Not found')${NC}"
}

# ==============================================================
# AUTO-COMPLETION SETUP
# ==============================================================

# Function to setup completion based on shell
setup_artisan_completion() {
    if command -v php >/dev/null 2>&1 && [ -f "artisan" ]; then
        # Check if Laravel completion command exists
        if php artisan completion --help >/dev/null 2>&1; then
            if [ -n "$ZSH_VERSION" ]; then
                # ZSH completion
                if [ ! -f ~/.artisan-completion.zsh ]; then
                    php artisan completion zsh > ~/.artisan-completion.zsh 2>/dev/null || {
                        # Fallback completion for older Laravel versions
                        cat > ~/.artisan-completion.zsh << 'EOF'
#compdef php artisan pa
_artisan_commands=(
    'serve:Start development server'
    'migrate:Run database migrations'
    'migrate:fresh:Drop all tables and re-run migrations'
    'make:model:Create a new Eloquent model'
    'make:controller:Create a new controller'
    'make:migration:Create a new migration'
    'route:list:List all registered routes'
    'cache:clear:Flush the application cache'
    'config:clear:Remove the configuration cache file'
    'view:clear:Clear all compiled view files'
    'tinker:Interact with your application'
    'test:Run the application tests'
    'down:Put application in maintenance mode'
    'up:Bring application out of maintenance mode'
    'key:generate:Set the application key'
    'storage:link:Create a symbolic link'
    'optimize:Cache the framework bootstrap files'
    'optimize:clear:Remove the cached bootstrap files'
    'queue:work:Start processing jobs'
    'db:seed:Seed the database'
)

_artisan() {
    _describe 'artisan commands' _artisan_commands
}

compdef _artisan php artisan pa
EOF
                    }
                fi
                source ~/.artisan-completion.zsh 2>/dev/null
                
            elif [ -n "$BASH_VERSION" ]; then
                # BASH completion
                if [ ! -f ~/.artisan-completion.bash ]; then
                    php artisan completion bash > ~/.artisan-completion.bash 2>/dev/null || {
                        # Fallback completion for older Laravel versions
                        cat > ~/.artisan-completion.bash << 'EOF'
_artisan_completion() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    commands="serve migrate migrate:fresh migrate:rollback make:model make:controller make:migration route:list cache:clear config:clear view:clear tinker test down up key:generate storage:link optimize optimize:clear queue:work db:seed"
    
    if [[ ${cur} == * ]] ; then
        COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
        return 0
    fi
}

complete -F _artisan_completion php
complete -F _artisan_completion artisan
complete -F _artisan_completion pa
EOF
                    }
                fi
                source ~/.artisan-completion.bash 2>/dev/null
            fi
        fi
    fi
}

# ==============================================================
# HELP FUNCTION
# ==============================================================

pahelp() {
    echo -e "${BLUE}🔧 Laravel Artisan Helper - Available Shortcuts:${NC}"
    echo ""
    echo -e "${YELLOW}Basic Commands:${NC}"
    echo "  pa          - php artisan"
    echo "  pas         - php artisan serve"
    echo "  pat         - php artisan tinker"
    echo "  patest      - php artisan test"
    echo ""
    echo -e "${YELLOW}Database:${NC}"
    echo "  pam         - php artisan migrate"
    echo "  pamf        - php artisan migrate:fresh"
    echo "  pamfs       - php artisan migrate:fresh --seed"
    echo "  pads        - php artisan db:seed"
    echo ""
    echo -e "${YELLOW}Code Generation:${NC}"
    echo "  pamkm       - php artisan make:model"
    echo "  pamkc       - php artisan make:controller"
    echo "  pamkmi      - php artisan make:migration"
    echo "  pamkall     - Create model + migration + controller + factory"
    echo ""
    echo -e "${YELLOW}Cache & Optimization:${NC}"
    echo "  pac         - php artisan cache:clear"
    echo "  paclear     - Clear all caches"
    echo "  pacache     - Cache routes, config, views"
    echo "  paoptimize  - Full production optimization"
    echo ""
    echo -e "${YELLOW}Custom Functions:${NC}"
    echo "  pasetup     - Quick project setup"
    echo "  pafresh     - Fresh installation"
    echo "  paprod      - Production optimization"
    echo "  painfo      - Show Laravel info"
    echo "  padev       - Development server with custom host/port"
    echo ""
    echo -e "${GREEN}💡 Tip: Use tab completion for artisan commands!${NC}"
}

# ==============================================================
# INITIALIZATION
# ==============================================================

# Setup completion when script is sourced
setup_artisan_completion

echo -e "${GREEN}✅ Laravel Artisan Helper loaded successfully!${NC}"
echo -e "${BLUE}📚 Type 'pahelp' to see all available shortcuts${NC}"
echo -e "${YELLOW}🚀 Happy coding with Laravel! 😎${NC}"