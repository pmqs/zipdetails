echo alpha >alpha
echo beta >beta
echo gamma >gamma
echo delta >delta

zip -X test.zip alpha beta gamma delta

rm alpha beta gamma delta