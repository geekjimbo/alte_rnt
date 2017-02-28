Rails.application.routes.draw do
  resources :controllers
  get 'sessions/new'

  root            'static_pages#home' 
  get 'asientos' => 'asientos#index'
  get 'asientos_new' => 'asientos#new'
  get 'concesion_direct_new' => 'concesion_directs#new'
  get 'recurso_numerico_new' => 'recurso_numericos#new'
  get 'orden_acceso_interconexion_new' => 'orden_acceso_interconexions#new'
  get 'resolucion_ubicacion_equipo_new' => 'resolucion_ubicacion_equipos#new'
  get 'sancion_new' => 'sancions#new'
  get 'permiso_new' => 'permisos#new'
  get 'precios_tarifa_new' => 'precios_tarifas#new'
  get 'autorizacion_new' => 'autorizacions#new'
  get 'convenio_privado_new' => 'convenio_privados#new'
  get 'consecion_anterior_new' => 'consecion_anteriors#new'
  get 'consecion_publica_new' => 'consecion_publicas#new'
  get 'reglamento_tecnico_new' => 'reglamento_tecnicos#new'
  get 'lab_new' => 'labs#new'
  get 'arbitro_new' => 'arbitros#new'
  get 'homologacion_new' => 'homologacions#new'
  get 'fonatel_new' => 'fonatels#new'
  get 'convenio_internacional_new' => 'convenio_internacionals#new'
  get 'norma_new' => 'normas#new'
  get 'convenio_ubicacion_equipo_new' => 'convenio_ubicacion_equipos#new'
  get 'contrato_adhesion_new' => 'contrato_adhesions#new'
  get 'oferta_interconexion_new' => 'oferta_interconexions#new'
  get 'acuerdo_acceso_interconexion_new' => 'acuerdo_acceso_interconexions#new'
  get 'asientos_create' => 'asientos#show'
  get 'asientos_edit' => 'asientos#edit'
  get 'help'   => 'static_pages#help'
  get 'about'  => 'static_pages#about'
  get 'contact'=> 'static_pages#contact'
  get 'signup'  =>  'users#new'
  get 'login'   =>  'sessions#new'
  post 'login'  =>  'sessions#create'
  get 'logout'  =>  'sessions#destroy'
  delete 'logout' => 'sessions#destroy'
  get 'form' => 'form#sancionimpuesta'

  get 'operador_regulados/:id/get_json', :controller=> 'operador_regulados', :action=>'get_json'
  get 'historico/:id', :controller=> 'asientos', :action=>'get_historico'
  get 'historico', :controller=> 'asientos', :action=>'get_historico'

  resources :users
  resources :operador_regulados
  resources :sci_servicios
  resources :recurso_numericos
  resources :convenio_privados
  resources :orden_acceso_interconexions
  resources :resolucion_ubicacion_equipos
  resources :sancions
  resources :asientos
  resources :permisos
  resources :espectros
  resources :consecion_publicas
  resources :concesion_directs
  resources :autorizacions
  resources :consecion_anteriors
  resources :reglamento_tecnicos
  resources :labs
  resources :arbitros
  resources :homologacions
  resources :fonatels
  resources :convenio_internacionals
  resources :normas
  resources :convenio_ubicacion_equipos
  resources :contrato_adhesions
  resources :oferta_interconexions
  resources :acuerdo_acceso_interconexions
  resources :detalle_recurso_numericos
  resources :precios_tarifas
end
