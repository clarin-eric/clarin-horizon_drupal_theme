<?php
/**
 * @file
 * The primary PHP file for this theme.
 */

/**
 * Overrides theme_preprocess_html().
 */
function CLARIN_Horizon_preprocess_html(&$vars) {
  $compatibilityModeOff = array(
    '#type' => 'html_tag',
    '#tag' => 'meta',
    '#attributes' => array(
      'http-equiv' => 'X-UA-Compatible',
      'content' => 'IE=edge'
    )
  );
  
  // Add header meta tag for IE to head
  drupal_add_html_head($compatibilityModeOff, 'compatibilityModeOff');
}

/**
 * Overrides theme_menu_link().
 */
function CLARIN_Horizon_menu_link__menu_block($variables) {
	return theme_menu_link($variables);
}

/**  
 * Custumise login page
 */     
function CLARIN_Horizon_theme() {      
  $items = array();
  // create custom user-login.tpl.php
  $items['user_login'] = array(
  'render element' => 'form',        
  'path' => drupal_get_path('theme', 'CLARIN_Horizon') . '/templates',
  'template' => 'user-login',                    
  'preprocess functions' => array(  
  'CLARIN_Horizon_preprocess_user_login'
  ),                 
 );                        
return $items;                                                                                                               
}                           
                          
function CLARIN_Horizon_form_user_login_alter(&$form, $form_state) {
    $form['name']['#title'] = 'E-mail address';
}

?>
