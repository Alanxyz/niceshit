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
