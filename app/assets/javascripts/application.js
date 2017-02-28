// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require prototype
//= require effects
//= require bootstrap
//= require bootstrap-datepicker
//= require turbolinks
//= require_tree 

function toggle_spinner(link){
  jQuery("#spinner,#anatext_submit_button").toggle()
}

function remove_fields(link, association){
    $(link).previous("input[type=hidden]").value = "1";
    $(link).up().hide();
    //$(link).up(".fields").hide();

};

function turn_on_historico(link, association){
    $(link).previous().value = "1";
    //$(link).up().hide();
    //$(link).up(".fields").hide();

};

function frecuencia_fields(link) {
  var new_id = new Date().getTime();
  var desde = link.id.sub(/tipo_frecuencia/,"desde");
  var hasta = link.id.sub(/tipo_frecuencia/,"hasta");
  var tx_desde = link.id.sub(/tipo_frecuencia/,"tx_desde");
  var tx_hasta = link.id.sub(/tipo_frecuencia/,"tx_hasta");
  var rx_desde = link.id.sub(/tipo_frecuencia/,"rx_desde");
  var rx_hasta = link.id.sub(/tipo_frecuencia/,"rx_hasta");
  var selected = jQuery("#"+link.id+" :selected").text(); 
  // habilitar y deshabilitar campos dinamicamente
  if (selected == "Frecuencia") {
    jQuery("#"+desde).prop("disabled", false);
    jQuery("#"+hasta).prop("disabled", true);
    jQuery("#"+tx_desde).prop("disabled", true);
    jQuery("#"+tx_hasta).prop("disabled", true);
    jQuery("#"+rx_desde).prop("disabled", true);
    jQuery("#"+rx_hasta).prop("disabled", true);

    jQuery("#"+hasta).val("");
    jQuery("#"+tx_desde).val("");
    jQuery("#"+tx_hasta).val("");
    jQuery("#"+rx_desde).val("");
    jQuery("#"+rx_hasta).val("");
  }
  if (selected == "Frecuencia Rx-Tx") {
    jQuery("#"+desde).prop("disabled", true);
    jQuery("#"+hasta).prop("disabled", true);
    jQuery("#"+tx_desde).prop("disabled", false);
    jQuery("#"+tx_hasta).prop("disabled", true);
    jQuery("#"+rx_desde).prop("disabled", true);
    jQuery("#"+rx_hasta).prop("disabled", false);

    jQuery("#"+desde).val("");
    jQuery("#"+hasta).val("");
    jQuery("#"+tx_hasta).val("");
    jQuery("#"+rx_desde).val("");
  }
  if (selected == "Rango Frecuencias") {
    jQuery("#"+desde).prop("disabled", false);
    jQuery("#"+hasta).prop("disabled", false);
    jQuery("#"+tx_desde).prop("disabled", true);
    jQuery("#"+tx_hasta).prop("disabled", true);
    jQuery("#"+rx_desde).prop("disabled", true);
    jQuery("#"+rx_hasta).prop("disabled", true);
    
    jQuery("#"+tx_desde).val("");
    jQuery("#"+tx_hasta).val("");
    jQuery("#"+rx_desde).val("");
    jQuery("#"+rx_hasta).val("");
  }
  if (selected == "Rango Frecuencias Rx-Tx") {
    jQuery("#"+desde).prop("disabled", true);
    jQuery("#"+hasta).prop("disabled", true);
    jQuery("#"+tx_desde).prop("disabled", false);
    jQuery("#"+tx_hasta).prop("disabled", false);
    jQuery("#"+rx_desde).prop("disabled", false);
    jQuery("#"+rx_hasta).prop("disabled", false);

    jQuery("#"+desde).val("");
    jQuery("#"+hasta).val("");
  }
  if (selected == "Seleccionar Tipo Frecuencia") {
    jQuery("#"+desde).prop("disabled", true);
    jQuery("#"+hasta).prop("disabled", true);
    jQuery("#"+tx_desde).prop("disabled", true);
    jQuery("#"+tx_hasta).prop("disabled", true);
    jQuery("#"+rx_desde).prop("disabled", true);
    jQuery("#"+rx_hasta).prop("disabled", true);

    jQuery("#"+desde).val("");
    jQuery("#"+hasta).val("");
    jQuery("#"+tx_desde).val("");
    jQuery("#"+tx_hasta).val("");
    jQuery("#"+rx_desde).val("");
    jQuery("#"+rx_hasta).val("");
  }
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_"+association, "g");
  $(link).up().insert({
    before: content.replace(regexp, new_id)
   });
  //var x = content.replace(regexp, new_id);
  //console.log(x)
}

function add_zona_fields(link, association, content) {
  //var my_string = $(link).up().up().up().down().next().next().next().id;
  var my_string = ""
  if (content.match(/autorizacion/) != null)
    my_string = $(link).up().up().up().down()
  else {
    if ($(link).up().up().up().down().down().down().down() != null)
      my_string = $(link).up().up().up().down().down().down().down().id;
    if (my_string == "") 
      my_string = $(link).up().up().up().up().next().id;
    //console.log(my_string);
    var my_id = ""
    var the_id = my_string.match(/_(\d*)_/)
    if (the_id != null) {
      my_id = my_string.match(/_(\d*)_/)[0].gsub(/_/,"");
      //console.log(my_id);
      content = content.gsub(/frecuencia_espectro_attributes_(\d*)_/,"frecuencia_espectro_attributes_"+my_id+"_").gsub(/frecuencia_espectro_attributes\]\[(\d*)\]/,"frecuencia_espectro_attributes]["+my_id+"]")
    }
  }
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_"+association, "g");
  $(link).up().insert({
    before: content.replace(regexp, new_id)
   });
  //var x = content.replace(regexp, new_id);
  //console.log(x)
}

function get_operadores(clase,id){ //calls this function when the selected value changes 
    jQuery.get("/operador_regulados/"+id.value+"/get_json",function(data, status, xhr){ //does ajax call to the invoice route we set up above 
      //var x = jQuery.parseJSON('{"nombre": "Bryan Ruiz", "posicion": "crack"}');
      var x = jQuery.parseJSON(data);
      var my_id = id.id.gsub(/_operador_regulados_id/,"")
      //debugger;
      //console.log(x);
      //console.log(x.nombre);
      jQuery("#"+my_id+"_nombre_operador").val(x.nombre); 
      jQuery("#"+my_id+"_identificacion_operador").val(x.identificacion); 
      jQuery("#"+my_id+"_nombre_representante_legal").val(x.nombre_representante_legal); 
      jQuery("#"+my_id+"_cedula_representante_legal").val(x.cedula_representante_legal); 
    })
};


function get_operador(clase,id){ //calls this function when the selected value changes 
    jQuery.get("/operador_regulados/"+id+"/get_json",function(data, status, xhr){ //does ajax call to the invoice route we set up above 
      //var x = jQuery.parseJSON('{"nombre": "Bryan Ruiz", "posicion": "crack"}');
      var x = jQuery.parseJSON(data);
      var asiento_string = "_asiento_attributes"
      var my_id = ""
      //debugger;
      if (clase == "operadores_convenio_ubicacion_equipos") {
         asiento_string = ""
         my_id = id
      }
      if ((clase == "permiso") || (clase == "concesion_direct") || (clase == "consecion_anterior") || (clase == "consecion_publica")) {
         asiento_string = "_espectro_attributes_asiento"
      }
      if (clase == "autorizacion")
         asiento_string = "_asiento"
      //console.log(x);
      //console.log(x.nombre);
      jQuery("#"+clase+asiento_string+"_nombre_operador").val(x.nombre); 
      jQuery("#"+clase+asiento_string+"_identificacion_operador").val(x.identificacion); 
      jQuery("#"+clase+asiento_string+"_nombre_representante_legal").val(x.nombre_representante_legal); 
      jQuery("#"+clase+asiento_string+"_cedula_representante_legal").val(x.cedula_representante_legal); 
    })
};

function cantones_list(campo) {
 canton = campo.id.replace('_provincia','_canton');
 if (typeof lista_cantones == 'undefined')
   lista_cantones = jQuery('#'+canton).html()
 //cantones = jQuery('#'+canton).html()
 
 //jQuery('#permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_0_provincia').change ->
 provincia = jQuery('#'+campo.id+' :selected').text()
 options = jQuery(lista_cantones).filter("optgroup[label="+provincia+"]").html()
 //if options
 jQuery('#'+canton).html(options)

 distrito = campo.id.replace('_provincia','_distrito');
 if (typeof lista_distritos == 'undefined')
   lista_distritos = jQuery('#'+distrito).html()
 
 canton = jQuery('#'+campo.id+' :selected').text()
 options = jQuery(lista_distritos).filter("optgroup[label="+canton+"]").html()
 jQuery('#'+distrito).html(options)
 //else
 // jQuery('#permiso_espectro_attributes_frecuencia_attributes_0_zona_attributes_0_canton').empty()
};

function distritos_list(campo) {
 distrito = campo.id.replace('_canton','_distrito');
 if (typeof lista_distritos == 'undefined')
   lista_distritos = jQuery('#'+distrito).html()
 
 canton = jQuery('#'+campo.id+' :selected').text()
 options = jQuery(lista_distritos).filter("optgroup[label="+canton+"]").html()
 jQuery('#'+distrito).html(options)
};
