#!/bin/bash

#Força os comandos darem erro, mesmo se estiver usando pipe
set -euo pipefail

# Função que exibe textos como títulos para melhor separação dos logs
function log() {
    local diff half before after
    diff=$((100 - $(echo -n "$1" | iconv -f utf8 -t ascii//TRANSLIT | wc -m)))
    half=$((diff / 2))
    before=$(awk -v count=$half 'BEGIN { while (i++ < count) printf " " }')
    after=$(awk -v count=$((half + diff - (half * 2))) 'BEGIN { while (i++ < count) printf " " }')
    printf "\x1b[%sm%s%s%s\x1b[0m\n" "0;30;44" "$before" "$1" "$after"
}

function main() {
    if [[ "$EUID" -eq 0 ]]; then
        echo "Não execute este script como root."
        exit 1
    fi

    log "Obtêm o caminho absoluto do script"
    script_path=$(realpath "$0")
    script_folder=$(dirname "$script_path")

    log "Entra na pasta do script (Deploy)"
    cd "$script_folder"

    log "Pasta raiz do projeto"
    project_folder=$(realpath "../")

    log "Deletando pasta vendor"
    sudo rm -rf "$project_folder/vendor"

    log "Copiando o env"
    if [[ ! -f "$project_folder/.env" ]]; then
        sudo cp "$project_folder/.env.example" "$project_folder/.env"
    fi

    log "Adicionando exceção ao Git sobre permissões da pasta de projeto"
    git config --global --add safe.directory "$project_folder"
    log "$project_folder"

    log "build ambiente"
    docker compose up -d --build

    log "Executando composer"
    docker compose exec -T app bash -c "composer install"

    log "Gerando key"
    docker compose exec -T app bash -c "php artisan key:generate"

    log "Rodando migrations"
    docker compose exec -T app bash -c "php artisan migrate --seed"
}

main "$@"
