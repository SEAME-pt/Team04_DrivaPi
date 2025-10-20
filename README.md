# SEAME Automotive Journey - DrivaPi Team04

[![Requirements Checks](https://github.com/SEAME-pt/Team04_DrivaPi/workflows/Requirements%20Checks%20(TSF%20Official)/badge.svg)](https://github.com/SEAME-pt/Team04_DrivaPi/actions)

**Desenvolvimento de veículo autónomo com conformidade TSF (Trustable Software Framework)**

---

## 🎯 Metodologia: Eclipse TSF Oficial

Este projeto usa **exclusivamente ferramentas oficiais Eclipse TSF**:

✅ **trudag** - Gestão de requisitos e traceability (Eclipse Trustable)
✅ **doorstop** - Backend de requisitos estruturados
❌ **Sem scripts Python personalizados**

---

## 🚀 Quick Start

### 1. Clonar Repositório
```bash
git clone https://github.com/SEAME-pt/Team04_DrivaPi.git
cd Team04_DrivaPi
```

### 2. Setup Ambiente TSF
```bash
# Criar virtualenv
python3 -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Instalar ferramentas oficiais TSF
pip install --upgrade pip
pip install doorstop pyyaml

# Instalar Trustable oficial
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable
cd /tmp/trustable
git checkout 2025.9.16
pip install .
cd -
```

### 3. Validar Requisitos
```bash
# Validação oficial TSF
trudag manage lint

# Atualizar estrutura Doorstop
trudag manage migrate
```

✅ **Setup completo!** Ver `docs/setup/SETUP.md` para detalhes.

---

## 📋 Estrutura de Requisitos

```
reqs/
├── urd/           # User Requirements (O QUE users precisam)
├── srd/           # System Requirements (COMO sistema fornece)
├── swd/           # Software Requirements (COMO software implementa)
├── lltc/          # Low-Level Test Cases (COMO verificar)
└── templates/     # Templates oficiais TSF
```

### V-Model (ISO 26262)
```
URD → SRD → SWD → LLTC
 ↓     ↓     ↓     ↓
User  Sys  Code  Tests
```

---

## 🔄 Workflow Diário

### Criar Requisito
```bash
# Opção A: Doorstop interativo
doorstop add SWD

# Opção B: Manual
cp reqs/templates/SWD-template.yml reqs/swd/SWD-XXX.yml
nano reqs/swd/SWD-XXX.yml

# Validar
trudag manage lint
```

### Criar Links de Traceability
```bash
# Ligar requisito filho → pai
doorstop link SWD-002 SRD-001

# Validar links
trudag manage lint
```

### Aprovar Requisito
```bash
# Aprovar (atualiza campo 'reviewed')
trudag manage set-item reqs/swd/SWD-002.yml

# Commit
git add reqs/swd/SWD-002.yml
git commit -m "review: Approve SWD-002"
```

### Criar Baseline
```bash
# Tag de baseline
git tag -a BASELINE-SWD-V1.0 -m "SWD baseline v1.0"
git push origin BASELINE-SWD-V1.0

# Exportar relatório Trustable
trudag report export --output artifacts/trustable-v1.0.zip
```

---

## 📝 Campos Obrigatórios (TSF)

Todos os requisitos **DEVEM** conter:

```yaml
SWD-001:
  ref: SWD-001                    # ID único (= nome ficheiro)
  header: "Título curto"
  text: |
    O sistema SHALL...            # Use "shall" para obrigatórios
  ASIL: B                         # A/B/C/D/QM
  Verification Method: Unit Test  # Método verificação
  links: [SRD-001]               # Requisito pai (traceability)
  reviewers:
    - name: "Nome Revisor"
      email: "email@example.com"
  reviewed: ''                    # Vazio até aprovação
  active: true
  derived: false
  normative: true
  level: 1.0
```

---

## 🛠️ Comandos TSF Essenciais

### Validação (executar diariamente)
```bash
trudag manage lint              # Validar requisitos
trudag manage migrate           # Atualizar estrutura
doorstop                        # Verificar Doorstop
```

### Doorstop (Backend)
```bash
doorstop add URD                # Criar requisito
doorstop edit URD-001           # Editar requisito
doorstop link SWD-001 SRD-001   # Criar link
doorstop publish all            # Gerar HTML
```

### Trudag (TSF)
```bash
trudag manage lint              # Validar
trudag manage migrate           # Migrar estrutura
trudag manage set-item <path>  # Aprovar requisito
trudag report export            # Exportar relatório
```

---

## 🏗️ Stack Técnica

### Hardware
- **Plataforma:** Raspberry Pi 5
- **Chassis:** PiRacer
- **Sensores:** Câmara, velocidade, temperatura
- **Display:** Qt HMI (800x480)

### Software
- **OS:** Automotive Grade Linux (AGL)
- **RTOS:** ThreadX (Azure RTOS)
- **GUI:** Qt Framework
- **Linguagem:** C++ (Rust em avaliação)
- **Requirements:** Doorstop + trudag (TSF oficial)

---

## 👥 Equipa DrivaPi

| Nome | Área | GitHub |
|------|------|--------|
| Hugo | Hardware & Fabrication | @hugo |
| João | OS & Development | @joao |
| Bernardo | Hardware Integration | @bernardo |
| Miguel | Agile/Scrum | @miguel |
| Melanie | GUI & Coordination | @melanie |

---

## 📖 Documentação

### Getting Started
- 🚀 **Setup:** `docs/setup/SETUP.md`
- 📚 **Quick Reference:** `docs/training/quick-reference.md`
- 🔄 **Workflow:** `docs/guides/requirements/workflow.md`

### Training
- 🎓 **TSF Training:** `docs/training/TSF-training.md`
- ✅ **Assessment:** `docs/training/assessment.md`
- 🧪 **Hands-on Lab:** `docs/training/hands-on-lab.md`

### Reference
- 📘 **TSF Overview:** `docs/reference/tsf-overview.md`
- 🔍 **V&V Plan:** `docs/reference/vv-plan.md`
- 📚 **Sources:** `docs/reference/sources.md`

---

## ✅ CI/CD Pipeline

GitHub Actions executa automaticamente em cada PR/push:

1. ✅ `doorstop` - Validar estrutura
2. ✅ `trudag manage lint` - Validar requisitos
3. ✅ `trudag manage migrate` - Atualizar estrutura
4. ✅ Upload artifacts TSF

**Ver:** `.github/workflows/reqs-checks.yml`

---

## 📊 Níveis ASIL (ISO 26262)

| ASIL | Risco | Exemplos | V&V |
|------|-------|----------|-----|
| QM | Sem segurança | Rádio, infotainment | Básico |
| A | Baixo | Luzes traseiras | Review + Tests |
| B | Baixo-Médio | Luzes travão | + Integration tests |
| C | Médio | ABS, ESC | + Coverage reports |
| D | Alto | Airbags, direção | + HIL + Formal methods |

---

## 🔗 Standards & Compliance

- ✅ **ISO 26262** - Functional Safety
- ✅ **ASPICE** - Automotive Software Process
- ✅ **Eclipse TSF** - Trustable Software Framework
- ✅ **AUTOSAR** - Architecture principles

---

## 📅 Progresso

### Sprint Atual
- **Período:** 13-25 Outubro 2025
- **Objetivo:** Estabelecer fundação software + completar integração hardware
- **Status:** 🟢 On track

### Stand-ups
- **Frequência:** Diária (manhã + tarde)
- **Docs:** `docs/team/standups/`

---

## 🤝 Contribuir

1. **Ler documentação:**
   - Setup: `docs/setup/SETUP.md`
   - Workflow: `docs/guides/requirements/workflow.md`

2. **Criar branch:**
   ```bash
   git checkout -b feat/SWD-XXX-description
   ```

3. **Criar/editar requisito** seguindo templates

4. **Validar:**
   ```bash
   trudag manage lint
   ```

5. **Criar PR** usando template `.github/PULL_REQUEST_TEMPLATE.md`

---

## 📜 License

MIT License - Ver `LICENSE`

---

## 🔗 Links Úteis

- **Eclipse Trustable:** https://codethinklabs.gitlab.io/trustable/trustable/
- **Doorstop Docs:** https://doorstop.readthedocs.io/
- **ISO 26262:** https://www.iso.org/standard/68383.html
- **ASPICE:** https://www.automotivespice.com/

---

## 📞 Contacto

- **GitHub:** https://github.com/SEAME-pt/Team04_DrivaPi
- **Issues:** https://github.com/SEAME-pt/Team04_DrivaPi/issues

---

**Última Atualização:** 20 Outubro 2025
**Versão:** 2.0 - TSF Oficial (trudag + doorstop apenas)
