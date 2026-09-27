# ne_animgear

Animações imersivas de troca de marchas para FiveM (Nova Esperança RP).

- **Carros:** Animação de braço alcançando a alavanca de câmbio (LHD).
- **Motas:** Animação de pé esquerdo engatando a marcha.
- **Controle total do veículo:** Configurado com flags de animação `48` (Upperbody + Player Control) para garantir que o condutor mantém 100% de aceleração, travagem e direção sem o veículo andar sozinho ou perder tração.
- **Verificações inteligentes:**
  - Validação de motor ligado (`GetIsVehicleEngineRunning`).
  - Bloqueio com travão de mão ativo.
  - Whitelist de classes de veículos e blacklist de veículos elétricos/sem marcha.

## Instalação

1. Coloca a pasta `ne_gearanim` (ou `ne_animgear`) na tua diretoria de `resources`.
2. Adiciona ao `server.cfg`:
   ```cfg
   ensure ne_gearanim
   ```
