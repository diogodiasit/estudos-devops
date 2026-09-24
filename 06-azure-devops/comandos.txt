# Fase 6 - Azure DevOps - Comandos praticados

## Clonar repositório vazio do Azure Repos
git clone https://diogodiasit@dev.azure.com/diogodiasit/estudos-devops-sre/_git/estudos-devops-sre estudos-devops-sre-azure

## Copiar projeto existente para o novo repositório
cp -r ~/estudos-devops-sre/projeto-agendamento ~/estudos-devops-sre-azure/

## Fluxo padrão de branch + PR (igual GitHub, so muda a interface)
git checkout -b nome-da-branch
git add .
git commit -m "mensagem"
git push origin nome-da-branch
# Depois: abrir PR pela interface do Azure DevOps

## Sincronizar main local com o Azure (mesmo principio do GitHub)
git checkout main
git pull
