::: {.callout-note collapse="true"}

## Output delle API Servizio Contratti Pubblici - SCP, per il CIG `918052266A`

```{.json code-line-numbers="true" }
{
  "help": "https://dati.mit.gov.it/catalog/api/3/action/help_show?name=datastore_search_sql",
  "success": true,
  "result": {
    "sql": "SELECT * from \"e1d07a87-1866-4def-ae77-f1084eac88e6\" WHERE cig LIKE '918052266A'",
    "records": [
      {
        "_id": 79706,
        "_full_text": "'-04':90,137 '-05':96 '-15':91 '-22':138 '-26':97 '-3':127 '/spinapp/it/bandi.page?internalservletactionpath=/extstr2/do/front/procurements/bandodetail.action&internalservletframedest=3&idbando=476329':135 '0.00000':123 '00':93,94,99,100 '012058091':86 '02':92,98 '05678721001':70 '1':110 '13':139 '1412023':1 '2022':89,95,136 '23569628.59000':66 '3987864.40000':122,124 '50.482':141 '50/2016':16 '53':140 '54':10 '60':12 '7':67,101,119 '71315400':126 '8519126':62 '918052266a':102 'accordi':26 'accordo':64,103 'agenzia':72 'ai':6 'aperta':5 'architettura':43 'artt':9 'attrazion':76 'calabria':117 'collaudo':114 'con':28 'conclusion':24 'd.lgs':14 'da':17 'deg':8,77 'del':13 'di':3,25,34,40,56,82,112,113,129 'e':11,38,42,54,60,79 'e.06':45 'e.21':44 'economici':31 'edificazion':52 'edifici':57 'fornitura':128 'gara':4 'geografico':116 'giancarlo':68 'i98i21000110001':125 'ia.02':47 'ia.04':48 'impresa':83 'ingegneria':41 'investimenti':78 'invitalia':71 'itf6':132 'l':75 'la':23,50 'laffidamento':33 'lavori':35 'lo':80 'lotto':108,115 'mastinu':69 'mediant':19 'mim':88 'n':15 'nazional':73 'non':61 'nuova':51 'og1':36,105 'og11':37,106 'operatori':30 'ordinario':63 'per':22,32,49,74 'piattaforma':20 'piu':29 'prestazional':109 'procedura':2 'pubblici':58 'quadro':27,65,104 'realizzarsi':18 'residenziali':59 'riqualificazion':55 'ristrutturazion':53 'rm':85 's.03':46 's.p.a':84 'sensi':7 'servizi':39,111,121,130 'si':87 'sicilia':118 'sub':107 'sviluppo':81 'telematica':21 'v':131 'www.serviziocontrattipubblici.it':134 'www.serviziocontrattipubblici.it/spinapp/it/bandi.page?internalservletactionpath=/extstr2/do/front/procurements/bandodetail.action&internalservletframedest=3&idbando=476329':133",
        "id_gara": "1412023",
        "oggetto_della_gara": "\"PROCEDURA DI GARA APERTA AI SENSI DEGLI ARTT. 54 E 60 DEL D.LGS. N. 50/2016, DA REALIZZARSI MEDIANTE PIATTAFORMA TELEMATICA, PER LA CONCLUSIONE DI ACCORDI QUADRO CON PIU OPERATORI ECONOMICI PER LAFFIDAMENTO DI LAVORI (OG1  OG11) E SERVIZI DI INGEGNERIA E ARCHITETTURA (E.21  E.06  S.03  IA.02  IA.04) PER LA NUOVA EDIFICAZIONE, RISTRUTTURAZIONE E RIQUALIFICAZIONE DI EDIFICI PUBBLICI RESIDENZIALI E NON.\"",
        "numero_gara_anac": "8519126",
        "settore": "Ordinario",
        "modalita_realizzazione": "Accordo quadro",
        "importo_gara": "23569628.59000",
        "num_tot_lotti": "7",
        "rup": "GIANCARLO MASTINU",
        "codice_fiscale_stazione_appaltante": "05678721001",
        "denominazione_stazione_appaltante": "INVITALIA Agenzia nazionale per l'attrazione degli investimenti e lo sviluppo di impresa S.p.A.",
        "provincia_stazione_appaltante": "RM",
        "codice_istat_stazione_appaltante": "012058091",
        "ufficio": null,
        "la_sa_agisce_per_conto_di_altro_soggetto": "Si",
        "soggetto_per_cui_agisce_la_sa": "MIMS",
        "data_pubblicazione_bando": "2022-04-15 02:00:00",
        "data_scadenza_bando": "2022-05-26 02:00:00",
        "id_lotto": "7",
        "cig": "918052266A",
        "oggetto_lotto": "\"ACCORDO QUADRO OG1 - OG11 - SUB - LOTTO PRESTAZIONALE 1  SERVIZI DI DI COLLAUDO  - LOTTO GEOGRAFICO: CALABRIA - SICILIA\"",
        "nr_lotto": "7",
        "somma_urgenza": "No",
        "tipo_appalto": "Servizi",
        "tipo_procedura": null,
        "criterio_aggiudicazione": null,
        "imp_lotto_netto_sicurezza": "3987864.40000",
        "imp_sicurezza": "0.00000",
        "imp_lotto": "3987864.40000",
        "cup": "I98I21000110001",
        "cpv": "71315400-3",
        "categoria_prevalente": "fornitura di servizi",
        "classifica": "V",
        "luogo_esecuzione_istat": null,
        "luogo_esecuzione_nuts": "ITF6",
        "url_bando": "https://www.serviziocontrattipubblici.it/SPInApp/it/bandi.page?internalServletActionPath=/ExtStr2/do/Front/Procurements/bandoDetail.action&internalServletFrameDest=3&idBando=476329",
        "data_pubblicazione_scp": "2022-04-22 13:53:50.482"
      }
    ],
    "fields": [
      {
        "id": "_id",
        "type": "int4"
      },
      {
        "id": "_full_text",
        "type": "tsvector"
      },
      {
        "id": "id_gara",
        "type": "text"
      },
      {
        "id": "oggetto_della_gara",
        "type": "text"
      },
      {
        "id": "numero_gara_anac",
        "type": "text"
      },
      {
        "id": "settore",
        "type": "text"
      },
      {
        "id": "modalita_realizzazione",
        "type": "text"
      },
      {
        "id": "importo_gara",
        "type": "text"
      },
      {
        "id": "num_tot_lotti",
        "type": "text"
      },
      {
        "id": "rup",
        "type": "text"
      },
      {
        "id": "codice_fiscale_stazione_appaltante",
        "type": "text"
      },
      {
        "id": "denominazione_stazione_appaltante",
        "type": "text"
      },
      {
        "id": "provincia_stazione_appaltante",
        "type": "text"
      },
      {
        "id": "codice_istat_stazione_appaltante",
        "type": "text"
      },
      {
        "id": "ufficio",
        "type": "text"
      },
      {
        "id": "la_sa_agisce_per_conto_di_altro_soggetto",
        "type": "text"
      },
      {
        "id": "soggetto_per_cui_agisce_la_sa",
        "type": "text"
      },
      {
        "id": "data_pubblicazione_bando",
        "type": "text"
      },
      {
        "id": "data_scadenza_bando",
        "type": "text"
      },
      {
        "id": "id_lotto",
        "type": "text"
      },
      {
        "id": "cig",
        "type": "text"
      },
      {
        "id": "oggetto_lotto",
        "type": "text"
      },
      {
        "id": "nr_lotto",
        "type": "text"
      },
      {
        "id": "somma_urgenza",
        "type": "text"
      },
      {
        "id": "tipo_appalto",
        "type": "text"
      },
      {
        "id": "tipo_procedura",
        "type": "text"
      },
      {
        "id": "criterio_aggiudicazione",
        "type": "text"
      },
      {
        "id": "imp_lotto_netto_sicurezza",
        "type": "text"
      },
      {
        "id": "imp_sicurezza",
        "type": "text"
      },
      {
        "id": "imp_lotto",
        "type": "text"
      },
      {
        "id": "cup",
        "type": "text"
      },
      {
        "id": "cpv",
        "type": "text"
      },
      {
        "id": "categoria_prevalente",
        "type": "text"
      },
      {
        "id": "classifica",
        "type": "text"
      },
      {
        "id": "luogo_esecuzione_istat",
        "type": "text"
      },
      {
        "id": "luogo_esecuzione_nuts",
        "type": "text"
      },
      {
        "id": "url_bando",
        "type": "text"
      },
      {
        "id": "data_pubblicazione_scp",
        "type": "text"
      }
    ]
  }
}

```
:::
