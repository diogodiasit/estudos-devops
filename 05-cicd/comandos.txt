# Comandos - Fase 5 (CI/CD)

python3 -m venv venv          # cria ambiente virtual isolado
source venv/bin/activate      # ativa o ambiente virtual
deactivate                    # sai do ambiente virtual

pip install pytest            # instala biblioteca de testes (dentro do venv)
pytest                        # roda todos os arquivos test_*.py da pasta atual

mkdir -p .github/workflows    # cria a pasta onde o GitHub Actions procura workflows
