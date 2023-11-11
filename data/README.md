Following files are generated with command:
```bash
cat controlN.vcf| grep -v '^##'| awk '{print $1, $2, $4, $5, "FREQ:", $10}'|awk -F: '{print $1, $8}' | sort -k6 > controlN.tsv
```
PCR and sequencing errors were generated in R. Code can be found in the [lab journal](https://cooked-prepared-e7e.notion.site/I-got-vaccinated-why-did-I-get-the-flu-7948c93c213445f897ccb4d9da0fccca?pvs=4).
