```mermaid
graph TD
ANAC[/ANAC/]
OpenBdap[/OpenBdap/]
SCP[/SCP/]
FocusPNRR[/Focus PNRR/]
CodiciCUP[Codici CUP]
CIG[Codici CIG]
OpenCUP([OpenCUP]) --> FocusPNRR --> CodiciCUP
CodiciCUP -->ANAC & OpenBdap
ANAC-->CIG
CIG-->SCP
```
