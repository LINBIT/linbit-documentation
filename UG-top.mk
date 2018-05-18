html: en-html
html-finalize: en-html-finalize
pdf: en-pdf
pdf-finalize: en-pdf-finalize

en-html:
	make -C en html

en-pdf:
	make -C en pdf

en-html-finalize:
	make -C en html-finalize

en-pdf-finalize:
	make -C en pdf-finalize

ja-html:
	make -C ja html

ja-pdf:
	make -C ja pdf

ja-html-finalize:
	make -C ja html-finalize

ja-pdf-finalize:
	make -C ja pdf-finalize
