cat ~/astro/FinalProc/PipFinal/Aux.txt | awk 'NR > 1' | awk '{print $1, $2, $3}' > ~/astro/FinalProc/PipFinal/Aux2.fdat
~/astro/FinalProc/Programs/gls/gls Aux2.fdat | tail -1  >> gls_results.dat
