# UCSE-ML-TP2-2024

## Integrantes:
* Bonafede, Marco
* Maidana, Ignacio

## trainValidationSplit.sh
Sirve para separar `train` en `train` y `validation`, creando la carpeta de `validation` y moviendo X% de las imágenes a la misma, creando previamente `train-backup` para mantener una copia del dataset intacto.

Los parámetros para correr el script se pueden editar cerca del principio del mismo.

El % de archivos a mover es impreciso, debido a operar con números enteros para que el script funcione con bash pelado. Se puede descomentar una línea para que sea más preciso, pero requiere instalar `bc`.

Dependiendo del valor del parámetro `seed` (usado para fijar el movimiento aleatorio de archivos), puede generar un error en el que intenta mover N archivos que ya movío previamente. En caso de ocurrir, lo único que pasa es que esa subcarpeta de `validation` tiene N archivos menos.
