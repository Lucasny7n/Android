# Coleta do dispositivo

Estado: **BLOCKED — nenhum S21 conectado em 2026-08-13**. O primeiro
`adb devices -l` da sessão exibiu apenas um emulador; a tentativa posterior do
script encontrou zero dispositivos. Em ambos os casos não houve `su`, escrita,
flash, reboot, acesso a userdata ou mudança de clock.

Quando o S21 Exynos 2100 estiver conectado:

```bash
cd '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC'
./tools/collect-s21-gpu-data.sh
```

O script deverá salvar diretório e SHA256 em `evidence/runtime/baseline-device/`.
Se detectar emulador, SoC/modelo incompatível ou `adb` ausente, terminará com
`BLOCKED` sem tentar `su`, flash, reboot ou escrita.

O script exige exatamente um device físico em estado `device`, recusa serial
`emulator-*`, exige indício `exynos2100`/`s5e9840` no `getprop` e lê somente:

- FVMAP G3D, UV, sysfs GPU/Mali/devfreq;
- thermal zones e cooling devices;
- propriedades, `uname` e dmesg filtrado;
- checksums do diretório e do tar de evidência.

Para monitoramento posterior (também somente leitura):

```bash
./tools/runtime-monitor.sh --serial SERIAL --interval 2 --samples 60
```

## Coleta entregue posteriormente — evidência primária

O aparelho não foi acessado nesta continuação. Porém a coleta root já entregue
foi validada localmente em
`evidence/runtime/baseline-device/s21-exynos2100-RQCRA01QZ9J-2026-08-13T03_28_30-03_00/`:
os 12 arquivos passaram `sha256sum -c SHA256SUMS`. Ela identifica SM-G991B
(`o1s`), Exynos 2100, Mali-G78 r0p1 e kernel Floppy 5.4.302. O FVMAP G3D e
`gpu_uv_percent=0` foram usados como baseline; `thermal-zones.txt` e
`cooling-devices.txt` tinham apenas cabeçalhos na coleta, portanto não são
tratados como telemetria térmica válida.

O script permanece read-only e é a forma correta de produzir uma coleta nova
depois de um boot manual. Nesta rodada não foi executado ADB, flash, reboot ou
qualquer escrita no telefone.
