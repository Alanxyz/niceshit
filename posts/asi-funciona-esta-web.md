# Así funciona esta web

![](assets/images/pepe-hacker.webp)

La funcionalidad de un blog no es mas que desplegar documentos de texto y distribuirlos mediante RSS o una subscripción por correo electrónico. Tareas simples que, por lo tanto, deberían realizarse de forma simple.

He visto muchas webs con menos necesidades usando tecnologías monstruosamente grandes innecesariamente. La mayoría de esas tecnologías son algo como _"Mírame. Soluciono este problema que no sabias que tenias y estas empresas me usan. Úsame en tu proyecto"_. Existen cosas útiles como [React](https://reactjs.org/), si tienes una plataforma compleja o esperas que se vuelva compleja. Cuando no es el caso, parece que hay quienes solo usan las cosas grandes para mostrarnos que saben usarlas.

## Características y estructura

Las cosas que resumen las capacidades de esta web son:

- Generación de paginas estáticas
- Solo HTML, CSS y JavaScript
- Soporte de para Markdown
- Feed mediante RSS
- Optimización de imágenes
- Flexibilidad, minimalismo e independencia

Para cumplir con esta lista solo recurrí a un script y una estructura de archivos coherente. Me tomo menos de una hora codificar la primer versión de esta web y no ha tenido cambios significativos desde entonces. Puedes encontrar el código actualizado [aquí](https://github.com/AstralCam/niceshit). 

La estructura de directorios es la siguiente

```
niceshit
├── Makefile
├── posts
├── images
├── templates
└── web
    ├── assets
    ├── scripts
    └── styles
```

En la carpeta `posts` se guardan _todas_ las paginas de esta web escritas en formato Markdown. La idea de esto es poder usar cualquier editor sin preocuparme por la compatibilidad del formato. Las paginas se exportan a código HTML mediante [Pandoc](https://pandoc.org/) usando alguna de las [plantillas](https://pandoc.org/MANUAL.html#templates) que se encuentran en `templates`. Las imágenes que puedan tener estos documentos se guardan en `images` y se optimizan para la web mediante [img2webp](https://developers.google.com/speed/webp/). Todo termina dentro de `web` listo para publicarse. Ademas, hay carpetas para colocar hojas de estilos y scripts para mejorar la apariencia e interactividad de la web.

### Script principal

El archivo `Makefile` es el corazón de la web. Es quien se encarga de automatizar las tareas mencionadas. Es un script del programa [Make](https://www.gnu.org/software/make/) que se encarga de procesar los documentos y generar las paginas de la web a partir de ellos. Detecta cambios en los archivos fuente y genera las paginas faltantes evitando generar toda la web de nuevo, lo que lo hace muy practico.


<details>
<summary>Ver archivo Makefile</summary>
```bash
URL ?= https://niceshit.ml/

MD_NOTES := $(shell ls -b posts/*.md)
HTML_NOTES := $(shell ls -b posts/*.md \
							| sed -e 's,posts/,web/,g' -e 's/.md/.html/g')
PNG_IMAGES := $(shell ls -b images/*.png)
GIF_IMAGES := $(shell ls -b images/*.gif)
WEBP_IMAGES := $(shell ls -b images/* \
							 | sed -e 's,^,web/assets/,g' -e 's,.png,.webp,g' -e 's,.gif,.webp,g')

all: $(HTML_NOTES) $(WEBP_IMAGES)

web/%.html: posts/%.md
	@echo procesando "$<"
		@pandoc -s \
			--metadata title="$$(grep '^# ' $< | sed -e 's,# ,,g')" \
			--template templates/post.html \
			--css styles/main.css \
			--css styles/ui.css \
			--css styles/theme.css \
		"$<" -o "$@"

web/assets/images/%.webp: images/%.png
	@img2webp "$<" -o "$@"

web/assets/images/%.webp: images/%.gif
	@gif2webp "$<" -o "$@"

feed:
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0">\n<channel>\n<title>NiceShit!</title>\n<link>https://niceshit.ml/</link>\n<description>Blog sobre ciencia, humanidades y tecnología.</description>\n' > web/feed.xml
	@for i in $(MD_NOTES); do \
		if [ $$i != 'posts/index.md' ] && [ $$i != 'posts/donaciones.md' ] && [ $$i != 'posts/404.md' ]; then \
			printf '<item>\n<title>%s</title>\n<link>%s</link>\n<guid>%s</guid>\n<description><![CDATA[ %s ]]></description>\n</item>\n' \
				"$$(grep '^# ' $$i | sed -e 's,# ,,g')" \
				"$$(echo "$(URL)$$i" | sed -e 's,posts/,,g' -e 's,.md,.html,g')" \
				"$$(echo "$(URL)$$i" | sed -e 's,posts/,,g' -e 's,.md,.html,g')" \
				"$$(pandoc $$i)" \
		; fi \
	;done >> web/feed.xml
	@printf '</channel>\n</rss>' >> web/feed.xml
	
clean:
	@rm web/*.html
```
</details>

Este Makefile permite manejar la web mediante comandos de consola. Estos son los disponibles.

- `make`: Genera las paginas nuevas paginas en HTML, actualiza las que han sido editadas y procesa las imágenes que aun no se han optimizado.
- `make feed`: Crea el feed RSS de todas las paginas sobreescribiendo el actual si este existe.
- `make clean`: Elimina todos los archivos HTML contenidos en la capeta `web`.

## Conclusión

Al final, todo esto es la manera en que he solucionado mi necesidad de un blog. Este pequeño sistema satisface mis necesidades y es suficiente para los pocos planes a futuro del blog. La intención principal es incentivar a crear webs propias sin acudir a software innecesario. Si alguien necesita algo que ya este hecho, recomiendo usar [WriteFreely](https://writefreely.org/) o [Blogit](https://pedantic.software/git/blogit) para usuarios que quieran algo mas mínimalista.

