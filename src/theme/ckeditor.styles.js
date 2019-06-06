/*
CLARIN styles for ckeditor
see: /var/www/localhost/htdocs/sites/all/libraries/ckeditor/styles.js
*/

if(typeof(CKEDITOR) !== 'undefined') {
    CKEDITOR.addStylesSet( 'drupal',
    [
            { name: 'Image Responsive', type: 'widget', widget: 'image', attributes: { 'class': 'img-responsive' } }
    ]);
}