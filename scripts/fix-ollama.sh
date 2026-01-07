#!/bin/bash
# =============================================================================
# Fix Ollama Service
# =============================================================================
# Diagnoses and fixes common Ollama issues:
# - Container not running
# - API not responding
# - Models not loaded
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
CONTAINER_NAME="neuro-ollama"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}              ${YELLOW}Fixing Ollama Service${NC}                         ${CYAN}║${NC}"
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

echo -e "${YELLOW}▶${NC} Checking Ollama status..."

# Check if container is running
if run_docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "  ${GREEN}✓ Container is running${NC}"
    
    # Check if API is responding
    if curl -s "$OLLAMA_URL/api/tags" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ API is responding${NC}"
        
        # Check for models
        MODEL_COUNT=$(curl -s "$OLLAMA_URL/api/tags" | grep -o '"name"' | wc -l)
        if [ "$MODEL_COUNT" -gt 0 ]; then
            echo -e "  ${GREEN}✓ $MODEL_COUNT model(s) available${NC}"
            echo -e "\n${GREEN}✓ Ollama is working correctly${NC}"
            
            # Show models
            echo -e "\n${CYAN}Available models:${NC}"
            curl -s "$OLLAMA_URL/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read model; do
                echo -e "  ${GREEN}•${NC} ${YELLOW}$model${NC}"
            done
            exit 0
        else
            echo -e "  ${YELLOW}⚠ No models installed${NC}"
            echo -e "\n${YELLOW}Run ./setup.sh to install required models${NC}"
            exit 0
        fi
    else
        echo -e "  ${YELLOW}⚠ Container running but API not responding${NC}"
        echo -e "  ${YELLOW}Restarting container...${NC}"
        run_docker restart "$CONTAINER_NAME"
    fi
else
    echo -e "  ${RED}✗ Container not running${NC}"
    
    # Check if container exists but stopped
    if run_docker ps -a | grep -q "$CONTAINER_NAME"; then
        echo -e "${YELLOW}▶${NC} Starting existing container..."
        run_docker start "$CONTAINER_NAME"
    else
        echo -e "${YELLOW}▶${NC} Starting with docker-compose..."
        run_docker compose up -d
    fi
fi

# Wait for Ollama to be ready
echo -e "\n${YELLOW}▶${NC} Waiting for Ollama to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0
while ! curl -s "$OLLAMA_URL/api/tags" >/dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo -e "${RED}✗ Ollama failed to start after $MAX_RETRIES attempts${NC}"
        echo -e "\n${YELLOW}Container logs:${NC}"
        run_docker logs "$CONTAINER_NAME" --tail 20
        exit 1
    fi
    echo -e "  Waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

echo -e "${GREEN}✓ Ollama is ready!${NC}"

# Show available models
echo -e "\n${CYAN}Available models:${NC}"
MODEL_COUNT=$(curl -s "$OLLAMA_URL/api/tags" | grep -o '"name"' | wc -l)
if [ "$MODEL_COUNT" -gt 0 ]; then
    curl -s "$OLLAMA_URL/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read model; do
        echo -e "  ${GREEN}•${NC} ${YELLOW}$model${NC}"
    done
else
    echo -e "  ${YELLOW}No models installed${NC}"
    echo -e "\n${CYAN}Run ./setup.sh to install required models${NC}"
fi

echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                  ${CYAN}Ollama is ready!${NC}                          ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
