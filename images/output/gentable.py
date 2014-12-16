def toString(i, digits):
	s = '%d' % i
	while len(s) < digits:
		s = '0' + s
	return s

template = '<a href="images/output/{}" data-lightbox="{}" data-title="{}"><img id="{}" src="images/output/{}" width="240px"></img></a>'
	
for i in range(90):
	ext = ''
	if i < 58:
		ext = '.png'
	else:
		ext = '.jpg'
	imgtag = 'result_' + toString(i, 4)
	imgid = 'fig_result_' + toString(i, 4)
	imgtitle = 'Input image ' + toString(i, 4)
	imgname = toString(i, 4) + ext

	imgtag2 = 'aligned_result_' + toString(i, 4)
	imgid2 = 'fig_aligned_result_' + toString(i, 4)
	imgtitle2 = 'Result image ' + toString(i, 4)
	imgname2 = 'aligned_' + toString(i,4) + ext
	
	left = template.format(imgname, imgtag, imgtitle, imgid, imgname)
	right = template.format(imgname2, imgtag2, imgtitle2, imgid2, imgname2)
	print '<table width="90%" left="5%" text-align="center">'
	print '<tr><td>' + left + '</td>' + '<td>' + right + '</td></tr>'
	print '</table>'
	
	
	