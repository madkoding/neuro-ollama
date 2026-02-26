# NEURO-OLLAMA

Servicio Ollama independiente para el ecosistema NEURO-OS.

## 📋 Descripción

Este repositorio contiene la configuración Docker para ejecutar Ollama como servicio independiente, separado del repositorio principal de NEURO-OS. Esto permite:

- Ejecutar Ollama en una máquina dedicada con GPU
- Compartir el servicio entre múltiples instancias de NEURO-OS
- Gestionar modelos de forma independiente
- Actualizar Ollama sin afectar otros servicios

## 🚀 Inicio Rápido

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/neuro-ollama.git
cd neuro-ollama

# 2. Iniciar Ollama
docker compose up -d

# 3. Instalar modelos requeridos
./scripts/setup.sh

# 4. Verificar que funciona
curl http://localhost:11434/api/tags
```

## 📦 Modelos

### Modelos Instalados

| Modelo | VRAM | Uso |
|--------|------|-----|
| `glm4:9b-chat-q8_0` | ~9 GB | Modelo principal con tools |
| `nomic-embed-text` | ~500 MB | Búsqueda semántica |

### Guía de Modelos Gratuitos de Ollama

Esta tabla muestra los modelos más populares disponibles en Ollama y sus capacidades:

> **Nota sobre Tools/AI Coding**: La columna "🛠️ Tools" indica compatibilidad con tool calling.
> - ✅ = Soporta herramientas (compatible con asistentes de código que usan tools)
> - ❌ = El modelo NO soporta tools en absoluto
> 
> *Última verificación: Enero 2026 con Ollama 0.13.5*

#### Modelos Pequeños (1-4 GB VRAM)

| Modelo | Params | VRAM | 🛠️ Tools | 👁️ Visión | 💻 Código | 🌐 Español | Notas |
|--------|--------|------|----------|-----------|-----------|------------|-------|
| `qwen2.5:1.5b` | 1.5B | ~1 GB | ✅ | ❌ | ⭐⭐ | ⭐⭐ | Ultra ligero |
| `qwen2.5:3b` | 3B | ~2 GB | ✅ | ❌ | ⭐⭐⭐ | ⭐⭐⭐ | Buen balance |
| `gemma2:2b` | 2B | ~1.5 GB | ❌ | ❌ | ⭐⭐ | ⭐⭐ | Google, rápido |
| `phi3:mini` | 3.8B | ~2.5 GB | ❌ | ❌ | ⭐⭐⭐ | ⭐⭐ | Microsoft |
| `llama3.2:3b` | 3B | ~2 GB | ✅ | ❌ | ⭐⭐⭐ | ⭐⭐ | Meta, versátil |
| `ministral-3:3b` | 3B | ~3 GB | ✅ | ✅ | ⭐⭐⭐ | ⭐⭐⭐ | **✅ Recomendado Light** |

#### Modelos Medianos (4-8 GB VRAM)

| Modelo | Params | VRAM | 🛠️ Tools | 👁️ Visión | 💻 Código | 🌐 Español | Notas |
|--------|--------|------|----------|-----------|-----------|------------|-------|
| `mistral:7b` | 7B | ~4 GB | ✅ | ❌ | ⭐⭐⭐ | ⭐⭐⭐ | Clásico, estable |
| `llama3.1:8b` | 8B | ~5 GB | ✅ | ❌ | ⭐⭐⭐⭐ | ⭐⭐⭐ | Meta, muy capaz |
| `gemma2:9b` | 9B | ~6 GB | ❌ | ❌ | ⭐⭐⭐ | ⭐⭐⭐ | Google, preciso |
| `qwen2.5:7b` | 7B | ~5 GB | ✅ | ❌ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Excelente en español |
| `ministral-3:8b` | 8B | ~6 GB | ✅ | ✅ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Con visión |
| `deepseek-coder:6.7b` | 6.7B | ~4 GB | ❌ | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Código (sin tools) |

#### Modelos Grandes (8-16 GB VRAM)

| Modelo | Params | VRAM | 🛠️ Tools | 👁️ Visión | 💻 Código | 🌐 Español | Notas |
|--------|--------|------|----------|-----------|-----------|------------|-------|
| `qwen2.5:14b` | 14B | ~9 GB | ✅ | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Muy capaz |
| `glm4:9b-chat-q8_0` | 9B | ~9 GB | ✅ | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **✅ Recomendado - GLM-4 Q8** |
| `llama3.1:70b-q4` | 70B | ~40 GB | ✅ | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Necesita mucha VRAM |
| `codellama:13b` | 13B | ~8 GB | ❌ | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Solo código |
| `mixtral:8x7b` | 47B | ~26 GB | ✅ | ❌ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | MoE (mucha VRAM) |
| `llava:13b` | 13B | ~10 GB | ❌ | ✅ | ⭐⭐⭐ | ⭐⭐⭐ | Solo visión |
| `deepseek-coder-v2:16b` | 16B | ~10 GB | ❌ | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Código (sin tools) |

#### Modelos de Embeddings

| Modelo | Dimensiones | VRAM | Uso |
|--------|-------------|------|-----|
| `nomic-embed-text` | 768 | ~500 MB | **Recomendado** - Búsqueda semántica general |
| `mxbai-embed-large` | 1024 | ~700 MB | Mayor precisión, más lento |
| `all-minilm` | 384 | ~100 MB | Ultra ligero, básico |
| `snowflake-arctic-embed` | 1024 | ~700 MB | Bueno para RAG |

#### Leyenda

| Símbolo | Significado |
|---------|-------------|
| 🛠️ ✅ | Soporta tool calling, compatible con asistentes AI |
| 🛠️ ❌ | NO soporta tools |
| 👁️ Visión | Puede analizar imágenes |
| 💻 Código | Capacidad de programación |
| 🌐 Español | Calidad de respuestas en español |

#### ¿Qué modelo elegir?

| Tarea | Modelo Recomendado | VRAM | Tools |
|-------|-------------------|------|---------|  
| **Desarrollo general** | `glm4:9b-chat-q8_0` | ~9 GB | ✅ |
| Modelo alternativo | `qwen2.5:7b` | ~5 GB | ✅ |
| Modelo ligero/rápido | `qwen2.5:3b` | ~2 GB | ✅ |
| Código especializado | `deepseek-coder:6.7b` | ~4 GB | ❌ |
| RAG / Embeddings | `nomic-embed-text` | ~500 MB | N/A |

> 💡 `glm4:9b-chat-q8_0` es el modelo principal: GLM-4 cuantizado Q8 con excelente rendimiento en código y razonamiento.
> 💡 `qwen2.5:7b` como alternativa con excelente soporte en español.### Instalación de Modelos

```bash
# Instalar modelos requeridos
./scripts/setup.sh

# Instalar un modelo adicional manualmente
docker exec -it neuro-ollama ollama pull modelo:tag
```

## 🔧 Configuración

### Variables de Entorno

| Variable | Default | Descripción |
|----------|---------|-------------|
| `OLLAMA_KEEP_ALIVE` | `-1` | Tiempo que el modelo permanece en memoria (-1 = indefinido) |
| `OLLAMA_CONTEXT_LENGTH` | `4096` | Longitud máxima del contexto |
| `OLLAMA_HOST` | `0.0.0.0` | Host donde escucha Ollama |

### GPU (NVIDIA)

El servicio está configurado para usar GPU NVIDIA por defecto. Requisitos:

1. **nvidia-container-toolkit** instalado:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install nvidia-container-toolkit
   sudo systemctl restart docker
   ```

2. **Driver NVIDIA** compatible

Para ejecutar **sin GPU** (solo CPU), edita `docker-compose.yml` y comenta:
```yaml
# runtime: nvidia
# deploy:
#   resources:
#     reservations:
#       devices:
#         - driver: nvidia
#           count: all
#           capabilities: [gpu]
```

## 🌐 Conexión desde NEURO-OS

### Desarrollo Local

En `neuro-os/.vscode/tasks.json` o `dev.sh`:
```bash
OLLAMA_URL=http://localhost:11434
```

### Docker (mismo host)

En `neuro-os/docker-compose.yml`:
```yaml
environment:
  - OLLAMA_URL=http://host.docker.internal:11434
```

### Docker (host remoto)

```yaml
environment:
  - OLLAMA_URL=http://192.168.1.100:11434
```

## 🔍 Diagnóstico

```bash
# Verificar estado
./scripts/fix-ollama.sh

# Ver logs
docker compose logs -f

# Ver modelos instalados
curl http://localhost:11434/api/tags | jq

# Verificar GPU
docker exec -it neuro-ollama nvidia-smi
```

## 📁 Estructura

```
neuro-ollama/
├── docker-compose.yml    # Configuración del servicio
├── scripts/              # Scripts de administración
│   ├── setup.sh          # Instalación de modelos
│   └── fix-ollama.sh     # Diagnóstico/reparación
└── README.md             # Este archivo
```

## 💾 Persistencia

Los modelos se almacenan en el volumen Docker `neuro-ollama-data`:

```bash
# Ver ubicación del volumen
docker volume inspect neuro-ollama-data

# Backup de modelos (opcional)
docker run --rm -v neuro-ollama-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/ollama-models.tar.gz /data
```

## 🔄 Actualización

```bash
# Actualizar imagen de Ollama
docker compose pull
docker compose up -d

# Los modelos se preservan en el volumen
```

## ⚠️ Troubleshooting

### Ollama no inicia

```bash
# Verificar logs
docker compose logs ollama

# Reiniciar
docker compose restart
```

### GPU no detectada

```bash
# Verificar nvidia-container-toolkit
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi

# Si falla, reinstalar toolkit
sudo apt-get install --reinstall nvidia-container-toolkit
sudo systemctl restart docker
```

### Modelos muy lentos

- Verificar que GPU está en uso: `docker exec -it neuro-ollama nvidia-smi`
- Reducir `OLLAMA_CONTEXT_LENGTH` si hay poca VRAM
- Usar modelos más pequeños (tier Light)

### Error de conexión desde neuro-os

1. Verificar que Ollama está corriendo: `curl http://localhost:11434/api/tags`
2. Verificar firewall: puerto 11434 debe estar abierto
3. En Docker, usar `host.docker.internal` en lugar de `localhost`

## 📄 Licencia

MIT License - Ver archivo LICENSE para detalles.

<!-- AUTO-UPDATE-DATE -->
**Última actualización:** 2026-02-26 08:38:05 -03
