#!/bin/bash

# Render README.rmd to README.md
Rscript -e 'rmarkdown::render("README.Rmd", encoding="UTF8")'

echo "README updated successfully!"
