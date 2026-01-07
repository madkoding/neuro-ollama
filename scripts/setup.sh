#!/bin/bash
# =============================================================================
# NEURO-OLLAMA Setup Script
# =============================================================================
# Downloads required models for NEURO-OS ecosystem.
#
# Models:
#   - qwen3:8b: Modelo de código (~5GB VRAM)
#   - qwen3:0.6b: Modelo ligero rápido (~500MB VRAM)
#   - nomic-embed-text: Embeddings para búsqueda semántica (~500MB)
#
# Usage:
#   ./setup.sh            # Install all models
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
CONTAINER_NAME="neuro-ollama"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}              ${YELLOW}NEURO-OLLAMA Setup${NC}                             ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"

# Function to run docker commands (handles group membership issue)
run_docker() {
    if docker ps >/dev/null 2>&1; then
        docker "$@"
    elif sg docker -c "docker ps" >/dev/null 2>&1; then
        sg docker -c "docker $*"
    else
        echo -e "${RED}Error: Cannot access Docker. Please ensure you're in the docker group.${NC}"
        exit 1
    fi
}

# Check if Ollama is running
check_ollama() {
    echo -e "${YELLOW}▶${NC} Checking Ollama status..."
    
    if ! run_docker ps | grep -q "$CONTAINER_NAME"; then
        echo -e "${YELLOW}  Ollama container not running. Starting...${NC}"
        run_docker compose up -d
        
        echo -e "${YELLOW}  Waiting for Ollama to be ready...${NC}"
        MAX_RETRIES=30
        RETRY_COUNT=0
        while ! curl -s "$OLLAMA_URL/api/tags" >/dev/null 2>&1; do
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
                echo -e "${RED}✗ Ollama failed to start after $MAX_RETRIES attempts${NC}"
                exit 1
            fi
            echo -e "  Waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
            sleep 2
        done
    fi
    
    if curl -s "$OLLAMA_URL/api/tags" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Ollama is ready${NC}"
    else
        echo -e "  ${RED}✗ Cannot connect to Ollama at $OLLAMA_URL${NC}"
        exit 1
    fi
}

# Pull a model with progress
pull_model() {
    local model=$1
    local description=$2
    
    echo -e "\n${BLUE}▶${NC} Pulling ${YELLOW}$model${NC} ($description)..."
    
    if run_docker exec "$CONTAINER_NAME" ollama pull "$model"; then
        echo -e "  ${GREEN}✓ $model installed successfully${NC}"
    else
        echo -e "  ${RED}✗ Failed to install $model${NC}"
        return 1
    fi
}

# Show installed models
show_models() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Installed Models:${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    
    curl -s "$OLLAMA_URL/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read model; do
        echo -e "  ${GREEN}•${NC} ${YELLOW}$model${NC}"
    done
}

# Preload a model into VRAM with keep_alive=-1
preload_into_vram() {
    local model=$1
    local tier=$2
    
    echo -e "\n${BLUE}▶${NC} Loading ${YELLOW}$model${NC} into VRAM ($tier)..."
    
    curl -s -X POST "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"$model\", \"prompt\": \"hi\", \"keep_alive\": -1, \"options\": {\"num_predict\": 1}}" > /dev/null
    
    echo -e "  ${GREEN}✓ $model loaded (keep_alive: forever)${NC}"
}

# Preload embedding model
preload_embedding() {
    local model=$1
    
    echo -e "\n${BLUE}▶${NC} Loading embedding ${YELLOW}$model${NC} into VRAM..."
    
    curl -s -X POST "$OLLAMA_URL/api/embeddings" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"$model\", \"prompt\": \"test\", \"keep_alive\": -1}" > /dev/null
    
    echo -e "  ${GREEN}✓ $model loaded (keep_alive: forever)${NC}"
}

# Show VRAM status
show_vram_status() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Models in VRAM:${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    
    curl -s "$OLLAMA_URL/api/ps" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read model; do
        echo -e "  ${GREEN}•${NC} ${YELLOW}$model${NC}"
    done
}

# Main setup
main() {
    check_ollama
    
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Installing required models${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    
    # Models
    pull_model "qwen3:8b" "Modelo de código"
    pull_model "qwen3:0.6b" "Modelo ligero rápido"
    pull_model "nomic-embed-text" "Embeddings for semantic search"
    
    show_models
    
    # Preload models into VRAM
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Preloading models into VRAM...${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    
    preload_into_vram "qwen3:8b" "Main model"
    preload_into_vram "qwen3:0.6b" "Light model"
    preload_embedding "nomic-embed-text:latest"
    
    show_vram_status
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}              ${CYAN}Setup Complete!${NC}                               ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo -e "  1. Keep this service running: ${CYAN}docker compose up -d${NC}"
    echo -e "  2. Ollama API available at ${CYAN}$OLLAMA_URL${NC}"
    echo -e "  3. Test API: ${CYAN}curl $OLLAMA_URL/api/tags${NC}"
}

main "$@"
