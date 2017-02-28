Rails.application.routes.draw do
  resources :controllers
  get 'sessions/new'

  root            'static_pages#home' 
  get 'asientos' => 'asientos#index'
  get 'asientos_create' => 'asientos#show'
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
end
