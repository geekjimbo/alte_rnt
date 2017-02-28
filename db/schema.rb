# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160311211036) do

  create_table "acuerdo_acceso_interconexions", force: :cascade do |t|
    t.string   "titulo_acuerdo",        limit: 4000
    t.date     "fecha_validez_acuerdo"
    t.boolean  "anexos"
    t.boolean  "adendas"
    t.text     "nota",                  limit: 2147483647
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "acuerdo_acceso_interconexions", ["adendas"], name: "index_acuerdo_acceso_interconexions_on_adendas"
  add_index "acuerdo_acceso_interconexions", ["anexos"], name: "index_acuerdo_acceso_interconexions_on_anexos"
  add_index "acuerdo_acceso_interconexions", ["fecha_validez_acuerdo"], name: "index_acuerdo_acceso_interconexions_on_fecha_validez_acuerdo"
  add_index "acuerdo_acceso_interconexions", ["titulo_acuerdo"], name: "index_acuerdo_acceso_interconexions_on_titulo_acuerdo"

  create_table "arbitros", force: :cascade do |t|
    t.string   "nombre_acreditado",         limit: 4000
    t.string   "identificacion_acreditado", limit: 4000
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.date     "fecha_vencimiento"
  end

  add_index "arbitros", ["identificacion_acreditado"], name: "index_arbitros_on_identificacion_acreditado"
  add_index "arbitros", ["nombre_acreditado"], name: "index_arbitros_on_nombre_acreditado"

  create_table "asientos", force: :cascade do |t|
    t.string   "num_asiento",                limit: 4000
    t.string   "num_asiento_original",       limit: 4000
    t.string   "acto_inscribible",           limit: 4000
    t.string   "tipo_asiento",               limit: 4000
    t.string   "tipo_inscripcion",           limit: 4000
    t.string   "numero_resolucion",          limit: 4000
    t.string   "nombre_resolucion",          limit: 4000
    t.text     "titulo_resolucion",          limit: 2147483647
    t.date     "fecha_resolucion"
    t.date     "fecha_solicitud"
    t.varchar  "nombre_operador",            limit: 200
    t.varchar  "identificacion_operador",    limit: 200
    t.varchar  "nombre_representante_legal", limit: 200
    t.varchar  "cedula_representante_legal", limit: 200
    t.string   "usuario",                    limit: 4000
    t.string   "enlace_documento",           limit: 4000
    t.string   "num_expediente_sutel",       limit: 4000
    t.integer  "operadorregulado_id",        limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "vigencia",                   limit: 4
    t.integer  "acto_id",                    limit: 4
    t.string   "acto_type",                  limit: 4000
    t.string   "fichero_file_name",          limit: 4000
    t.string   "fichero_content_type",       limit: 4000
    t.integer  "fichero_file_size",          limit: 4
    t.datetime "fichero_updated_at"
    t.string   "vigencia2",                  limit: 4000
  end

  add_index "asientos", ["acto_id"], name: "index_asientos_on_acto_id"
  add_index "asientos", ["acto_inscribible"], name: "index_asientos_on_acto_inscribible"
  add_index "asientos", ["acto_type"], name: "index_asientos_on_acto_type"
  add_index "asientos", ["cedula_representante_legal"], name: "index_asientos_on_cedula_representante_legal"
  add_index "asientos", ["fecha_resolucion"], name: "index_asientos_on_fecha_resolucion"
  add_index "asientos", ["fecha_solicitud"], name: "index_asientos_on_fecha_solicitud"
  add_index "asientos", ["identificacion_operador"], name: "index_asientos_on_identificacion_operador"
  add_index "asientos", ["nombre_resolucion"], name: "index_asientos_on_nombre_resolucion"
  add_index "asientos", ["num_asiento"], name: "index_asientos_on_num_asiento"
  add_index "asientos", ["num_asiento_original"], name: "index_asientos_on_num_asiento_original"
  add_index "asientos", ["numero_resolucion"], name: "index_asientos_on_numero_resolucion"
  add_index "asientos", ["operadorregulado_id"], name: "index_asientos_on_operador_regulado_id"
  add_index "asientos", ["tipo_asiento"], name: "index_asientos_on_tipo_asiento"
  add_index "asientos", ["tipo_inscripcion"], name: "index_asientos_on_tipo_inscripcion"
  add_index "asientos", ["vigencia"], name: "index_asientos_on_vigencia"

  create_table "autorizacions", force: :cascade do |t|
    t.string   "numero_publicacion_gaceta", limit: 4000
    t.string   "fecha_publicacion_gaceta",  limit: 4000
    t.string   "tipo_red",                  limit: 4000
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.date     "fecha_vencimiento"
  end

  add_index "autorizacions", ["fecha_publicacion_gaceta"], name: "index_autorizacions_on_fecha_publicacion_gaceta"
  add_index "autorizacions", ["numero_publicacion_gaceta"], name: "index_autorizacions_on_numero_publicacion_gaceta"
  add_index "autorizacions", ["tipo_red"], name: "index_autorizacions_on_tipo_red"

  create_table "cantons", force: :cascade do |t|
    t.string   "canton",     limit: 4000
    t.integer  "prov_id",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "cantons", ["prov_id"], name: "index_cantons_on_prov_id"

  create_table "concesion_directs", force: :cascade do |t|
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.date     "fecha_vencimiento"
    t.string   "tipo_red",          limit: 4000
  end

  create_table "consecion_anteriors", force: :cascade do |t|
    t.string   "adecuacion_poder_ejecutivo",        limit: 4000
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.date     "fecha_adecuacion_poder_ejecutivo"
    t.string   "numero_adecuacion_poder_ejecutivo", limit: 4000
  end

  create_table "consecion_publicas", force: :cascade do |t|
    t.string   "tipo_red",                     limit: 4000
    t.date     "fecha_publicacion"
    t.string   "numero_publicacion",           limit: 4000
    t.string   "contrato_concesion",           limit: 4000
    t.date     "fecha_emision"
    t.string   "numero_notificacion_refrendo", limit: 4000
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.date     "fecha_notificacion_refrendo"
    t.date     "fecha_vencimiento"
  end

  add_index "consecion_publicas", ["fecha_emision"], name: "index_consecion_publicas_on_fecha_emision"
  add_index "consecion_publicas", ["fecha_publicacion"], name: "index_consecion_publicas_on_fecha_publicacion"
  add_index "consecion_publicas", ["numero_notificacion_refrendo"], name: "index_consecion_publicas_on_numero_notificacion_refrendo"
  add_index "consecion_publicas", ["numero_publicacion"], name: "index_consecion_publicas_on_numero_publicacion"
  add_index "consecion_publicas", ["tipo_red"], name: "index_consecion_publicas_on_tipo_red"

  create_table "consecutivos", force: :cascade do |t|
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "contador_as", limit: 4
    t.integer  "contador_md", limit: 4
    t.boolean  "md",                    default: false
    t.boolean  "as",                    default: false
  end

  add_index "consecutivos", ["contador_as"], name: "index_consecutivos_on_contador_as"
  add_index "consecutivos", ["contador_md"], name: "index_consecutivos_on_contador_md"

  create_table "contrato_adhesions", force: :cascade do |t|
    t.string   "titulo_contrato", limit: 4000
    t.date     "fecha_vigencia"
    t.boolean  "estado_contrato"
    t.text     "nota",            limit: 2147483647
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "contrato_adhesions", ["estado_contrato"], name: "index_contrato_adhesions_on_estado_contrato"
  add_index "contrato_adhesions", ["fecha_vigencia"], name: "index_contrato_adhesions_on_fecha_vigencia"
  add_index "contrato_adhesions", ["titulo_contrato"], name: "index_contrato_adhesions_on_titulo_contrato"

  create_table "controllers", force: :cascade do |t|
    t.string   "Asiento",    limit: 4000
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "convenio_internacionals", force: :cascade do |t|
    t.string   "titulo_convenio",       limit: 4000
    t.string   "numero_ley_aprobacion", limit: 4000
    t.date     "fecha_vigencia"
    t.text     "enmiendas",             limit: 2147483647
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "convenio_internacionals", ["numero_ley_aprobacion"], name: "index_convenio_internacionals_on_numero_ley_aprobacion"
  add_index "convenio_internacionals", ["titulo_convenio"], name: "index_convenio_internacionals_on_titulo_convenio"

  create_table "convenio_privados", force: :cascade do |t|
    t.string   "titulo_convenio",   limit: 4000
    t.date     "fecha_suscripcion"
    t.integer  "num_anexos",        limit: 4
    t.text     "nota",              limit: 2147483647
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.date     "fecha_vencimiento"
    t.string   "adendas",           limit: 4000
  end

  add_index "convenio_privados", ["fecha_suscripcion"], name: "index_convenio_privados_on_fecha_suscripcion"
  add_index "convenio_privados", ["titulo_convenio"], name: "index_convenio_privados_on_titulo_convenio"

  create_table "convenio_ubicacion_equipos", force: :cascade do |t|
    t.string   "titulo_convenio",   limit: 4000
    t.date     "fecha_vencimiento"
    t.integer  "numero_anexos",     limit: 4
    t.boolean  "adendas"
    t.text     "nota",              limit: 2147483647
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "convenio_ubicacion_equipos", ["adendas"], name: "index_convenio_ubicacion_equipos_on_adendas"
  add_index "convenio_ubicacion_equipos", ["fecha_vencimiento"], name: "index_convenio_ubicacion_equipos_on_fecha_vencimiento"
  add_index "convenio_ubicacion_equipos", ["titulo_convenio"], name: "index_convenio_ubicacion_equipos_on_titulo_convenio"

  create_table "detalle_precios_tarifas", force: :cascade do |t|
    t.string   "tipo_precio_tarifa", limit: 4000
    t.string   "servicio",           limit: 4000
    t.string   "modalidad",          limit: 4000
    t.decimal  "precio_tarifa",                   precision: 18, scale: 0
    t.date     "fecha_vigencia"
    t.string   "estado",             limit: 4000
    t.integer  "precios_tarifas_id", limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "sci_servicios_id",   limit: 4
  end

  add_index "detalle_precios_tarifas", ["estado"], name: "idx_detalle_pyt_estado"
  add_index "detalle_precios_tarifas", ["modalidad"], name: "idx_detalle_pyt_modalidad"
  add_index "detalle_precios_tarifas", ["precios_tarifas_id"], name: "idx_precios_tarifas_detalle"
  add_index "detalle_precios_tarifas", ["sci_servicios_id"], name: "idx_detalle_pyt_servicios"
  add_index "detalle_precios_tarifas", ["servicio"], name: "idx_detalle_pyt_servicio"
  add_index "detalle_precios_tarifas", ["tipo_precio_tarifa"], name: "idx_detalle_pyt_tipo"

  create_table "detalle_recurso_numericos", force: :cascade do |t|
    t.string   "rango_numeracion",      limit: 4000
    t.string   "numero_asignado",       limit: 4000
    t.string   "tipo_recurso_numerico", limit: 4000
    t.text     "nota",                  limit: 2147483647
    t.integer  "recurso_numericos_id",  limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "detalle_recurso_numericos", ["recurso_numericos_id"], name: "index_detalle_recurso_numericos_on_recurso_numericos_id"

  create_table "distritos", force: :cascade do |t|
    t.string   "distrito",   limit: 4000
    t.integer  "canton_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "distritos", ["canton_id"], name: "index_distritos_on_canton_id"

  create_table "espectros", force: :cascade do |t|
    t.string   "clasificacion_uso_espectro", limit: 4000
    t.integer  "titulo_id",                  limit: 4
    t.string   "titulo_type",                limit: 4000
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "espectros", ["clasificacion_uso_espectro"], name: "index_espectros_on_clasificacion_uso_espectro"
  add_index "espectros", ["titulo_type", "titulo_id"], name: "index_espectros_on_titulo_type_and_titulo_id"

  create_table "fonatels", force: :cascade do |t|
    t.string   "titulo_informe", limit: 4000
    t.text     "nota",           limit: 2147483647
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "fonatels", ["titulo_informe"], name: "index_fonatels_on_titulo_informe"

  create_table "frec", force: :cascade do |t|
    t.string   "tipo_frecuencia",   limit: 4000
    t.integer  "ancho_banda_desde", limit: 4
    t.integer  "ancho_banda_hasta", limit: 4
    t.string   "unidad_desde",      limit: 4000
    t.string   "unidad_hasta",      limit: 4000
    t.integer  "espectro_id",       limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "desde",                          precision: 18, scale: 0
    t.decimal  "hasta",                          precision: 18, scale: 0
    t.decimal  "tx_desde",                       precision: 18, scale: 0
    t.decimal  "tx_hasta",                       precision: 18, scale: 0
    t.decimal  "rx_desde",                       precision: 18, scale: 0
    t.decimal  "rx_hasta",                       precision: 18, scale: 0
  end

  create_table "frecuencia_espectros", force: :cascade do |t|
    t.string   "tipo_frecuencia",   limit: 4000
    t.integer  "ancho_banda_desde", limit: 4
    t.integer  "ancho_banda_hasta", limit: 4
    t.string   "unidad_desde",      limit: 4000
    t.string   "unidad_hasta",      limit: 4000
    t.integer  "espectro_id",       limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "desde",             limit: 4000
    t.string   "hasta",             limit: 4000
    t.string   "tx_desde",          limit: 4000
    t.string   "tx_hasta",          limit: 4000
    t.string   "rx_desde",          limit: 4000
    t.string   "rx_hasta",          limit: 4000
  end

  create_table "homologacions", force: :cascade do |t|
    t.string   "numero_oficio_remision", limit: 4000
    t.date     "fecha_actualizacion"
    t.text     "nota",                   limit: 2147483647
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "homologacions", ["fecha_actualizacion"], name: "index_homologacions_on_fecha_actualizacion"
  add_index "homologacions", ["numero_oficio_remision"], name: "index_homologacions_on_numero_oficio_remision"

  create_table "labs", force: :cascade do |t|
    t.string   "nombre_acreditado", limit: 4000
    t.text     "nota",              limit: 2147483647
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "normas", force: :cascade do |t|
    t.date     "fecha_vigencia"
    t.string   "reforma",        limit: 4000
    t.text     "nota",           limit: 2147483647
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "normas", ["fecha_vigencia"], name: "index_normas_on_fecha_vigencia"

  create_table "oferta_interconexion_servicios", force: :cascade do |t|
    t.integer  "oferta_interconexions_id", limit: 4
    t.integer  "sci_servicios_id",         limit: 4
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.decimal  "precio",                                precision: 18, scale: 2
    t.string   "servicio",                 limit: 4000
  end

  add_index "oferta_interconexion_servicios", ["oferta_interconexions_id"], name: "index_oferta_interconexion_servicios_on_oferta_interconexions_id"
  add_index "oferta_interconexion_servicios", ["sci_servicios_id"], name: "index_oferta_interconexion_servicios_on_sci_servicios_id"

  create_table "oferta_interconexions", force: :cascade do |t|
    t.string   "numero_publicacion_gaceta", limit: 4000
    t.date     "fecha_publicacion_gaceta"
    t.text     "contenido_oferta",          limit: 2147483647
    t.date     "fecha_vencimiento"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "oferta_interconexions", ["fecha_publicacion_gaceta"], name: "index_oferta_interconexions_on_fecha_publicacion_gaceta"
  add_index "oferta_interconexions", ["fecha_vencimiento"], name: "index_oferta_interconexions_on_fecha_vencimiento"
  add_index "oferta_interconexions", ["numero_publicacion_gaceta"], name: "index_oferta_interconexions_on_numero_publicacion_gaceta"

  create_table "operador_regulados", force: :cascade do |t|
    t.varchar  "nombre",                     limit: 200
    t.varchar  "identificacion",             limit: 200
    t.varchar  "codigo_operador",            limit: 200
    t.varchar  "nombre_representante_legal", limit: 200
    t.varchar  "cedula_representante_legal", limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.varchar  "estado",                     limit: 200
  end

  create_table "operadores_acuerdo_acceso_interconexions", force: :cascade do |t|
    t.string   "nombre_operador",                  limit: 4000
    t.string   "identificacion_operador",          limit: 4000
    t.string   "nombre_representante_legal",       limit: 4000
    t.string   "cedula_representante_legal",       limit: 4000
    t.integer  "operador_regulados_id",            limit: 4
    t.integer  "acuerdo_acceso_interconexions_id", limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "operadores_acuerdo_acceso_interconexions", ["acuerdo_acceso_interconexions_id"], name: "idx_operadores_aai_aai"
  add_index "operadores_acuerdo_acceso_interconexions", ["cedula_representante_legal"], name: "operadores_aai_cedula_rep_legal"
  add_index "operadores_acuerdo_acceso_interconexions", ["identificacion_operador"], name: "operadores_aai_id_operador"
  add_index "operadores_acuerdo_acceso_interconexions", ["nombre_operador"], name: "operadores_aai_nombre_operador"
  add_index "operadores_acuerdo_acceso_interconexions", ["nombre_representante_legal"], name: "operadores_aai_rep_legal"
  add_index "operadores_acuerdo_acceso_interconexions", ["operador_regulados_id"], name: "idx_operadores_aai"

  create_table "operadores_convenio_ubicacion_equipos", force: :cascade do |t|
    t.integer  "convenio_ubicacion_equipos_id", limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "operador_regulados_id",         limit: 4
    t.string   "nombre_operador",               limit: 4000
    t.string   "identificacion_operador",       limit: 4000
    t.string   "nombre_representante_legal",    limit: 4000
    t.string   "cedula_representante_legal",    limit: 4000
  end

  add_index "operadores_convenio_ubicacion_equipos", ["cedula_representante_legal"], name: "idx_operadores_cue_cedula_rep_legal"
  add_index "operadores_convenio_ubicacion_equipos", ["convenio_ubicacion_equipos_id"], name: "idx_operadores_convenio_ubicacion_equipos"
  add_index "operadores_convenio_ubicacion_equipos", ["identificacion_operador"], name: "idx_operadores_cue_identificacion_operador"
  add_index "operadores_convenio_ubicacion_equipos", ["nombre_operador"], name: "idx_operadores_cue_nombre_operador"
  add_index "operadores_convenio_ubicacion_equipos", ["nombre_representante_legal"], name: "idx_operadores_cue_nombre_rep_legal"
  add_index "operadores_convenio_ubicacion_equipos", ["operador_regulados_id"], name: "idx_convenio_ubic_equipos_operadores"

  create_table "operadores_orden_acceso_interconexions", force: :cascade do |t|
    t.string   "nombre_operador",                limit: 4000
    t.string   "identificacion_operador",        limit: 4000
    t.string   "nombre_representante_legal",     limit: 4000
    t.string   "cedula_representante_legal",     limit: 4000
    t.integer  "operador_regulados_id",          limit: 4
    t.integer  "orden_acceso_interconexions_id", limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "operadores_orden_acceso_interconexions", ["cedula_representante_legal"], name: "idx_operadores_oai_cedula_rep_legal"
  add_index "operadores_orden_acceso_interconexions", ["identificacion_operador"], name: "idx_operadores_oai_id_operador"
  add_index "operadores_orden_acceso_interconexions", ["nombre_operador"], name: "idx_operadores_oai_nombre_operador"
  add_index "operadores_orden_acceso_interconexions", ["nombre_representante_legal"], name: "idx_operadores_oai_nombre_rep_legal"
  add_index "operadores_orden_acceso_interconexions", ["operador_regulados_id"], name: "idx_operadores_oai"
  add_index "operadores_orden_acceso_interconexions", ["orden_acceso_interconexions_id"], name: "idx_oai"

  create_table "operadores_resolucion_ubicacion_equipos", force: :cascade do |t|
    t.string   "nombre_operador",                 limit: 4000
    t.string   "identificacion_operador",         limit: 4000
    t.string   "nombre_representante_legal",      limit: 4000
    t.string   "cedula_representante_legal",      limit: 4000
    t.integer  "operador_regulados_id",           limit: 4
    t.integer  "resolucion_ubicacion_equipos_id", limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "operadores_resolucion_ubicacion_equipos", ["cedula_representante_legal"], name: "idx_operadores_rue_cedula_rep_legal"
  add_index "operadores_resolucion_ubicacion_equipos", ["identificacion_operador"], name: "idx_operadores_rue_id_operador"
  add_index "operadores_resolucion_ubicacion_equipos", ["nombre_operador"], name: "idx_operadores_rue"
  add_index "operadores_resolucion_ubicacion_equipos", ["nombre_representante_legal"], name: "idx_operadores_rue_rep_legal"
  add_index "operadores_resolucion_ubicacion_equipos", ["operador_regulados_id"], name: "idx_operadores_rue_operador_regulado"
  add_index "operadores_resolucion_ubicacion_equipos", ["resolucion_ubicacion_equipos_id"], name: "idx_operadores_rue_rue"

  create_table "ops", force: :cascade do |t|
    t.varchar  "nombre",                     limit: 200
    t.varchar  "identificacion",             limit: 200
    t.varchar  "codigo_operador",            limit: 200
    t.varchar  "nombre_representante_legal", limit: 200
    t.varchar  "cedula_representante_legal", limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.varchar  "estado",                     limit: 200
  end

  create_table "orden_acceso_interconexions", force: :cascade do |t|
    t.text     "nota",           limit: 2147483647
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.date     "fecha_vigencia"
  end

  create_table "permisos", force: :cascade do |t|
    t.string   "modalidad_permiso", limit: 4000
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "permisos", ["modalidad_permiso"], name: "index_permisos_on_modalidad_permiso"

  create_table "precios_tarifas", force: :cascade do |t|
    t.date     "fecha_publicacion_gaceta"
    t.string   "numero_publicacion_gaceta", limit: 4000
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "tipo_precio_tarifa",        limit: 4000
  end

  add_index "precios_tarifas", ["fecha_publicacion_gaceta"], name: "idx_preciostarifas_fecha_gaceta"
  add_index "precios_tarifas", ["numero_publicacion_gaceta"], name: "idx_preciostarifas_numero_gaceta"

  create_table "provs", force: :cascade do |t|
    t.string   "provincia",  limit: 4000
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "recurso_numericos", force: :cascade do |t|
    t.string   "rango_numeracion",      limit: 4000
    t.string   "numero_asignado",       limit: 4000
    t.string   "tipo_recurso_numerico", limit: 4000
    t.text     "nota",                  limit: 2147483647
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "recurso_numericos", ["numero_asignado"], name: "index_recurso_numericos_on_numero_asignado"
  add_index "recurso_numericos", ["rango_numeracion"], name: "index_recurso_numericos_on_rango_numeracion"
  add_index "recurso_numericos", ["tipo_recurso_numerico"], name: "index_recurso_numericos_on_tipo_recurso_numerico"

  create_table "reglamento_tecnicos", force: :cascade do |t|
    t.string   "titulo_reglamento",        limit: 4000
    t.string   "numero_aprobacion_aresep", limit: 4000
    t.date     "fecha_aprobacion"
    t.text     "nota",                     limit: 2147483647
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.date     "fecha_vigencia"
    t.text     "reformas",                 limit: 2147483647
  end

  add_index "reglamento_tecnicos", ["fecha_aprobacion"], name: "index_reglamento_tecnicos_on_fecha_aprobacion"
  add_index "reglamento_tecnicos", ["numero_aprobacion_aresep"], name: "index_reglamento_tecnicos_on_numero_aprobacion_aresep"
  add_index "reglamento_tecnicos", ["titulo_reglamento"], name: "index_reglamento_tecnicos_on_titulo_reglamento"

  create_table "resolucion_ubicacion_equipos", force: :cascade do |t|
    t.date     "fecha_vigencia"
    t.text     "nota",           limit: 2147483647
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "resolucion_ubicacion_equipos", ["fecha_vigencia"], name: "index_resolucion_ubicacion_equipos_on_fecha_vigencia"

  create_table "sancions", force: :cascade do |t|
    t.string   "tipo_sancion",   limit: 4000
    t.date     "fecha_vigencia"
    t.text     "nota",           limit: 2147483647
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "sancions", ["fecha_vigencia"], name: "index_sancions_on_fecha_vigencia"
  add_index "sancions", ["tipo_sancion"], name: "index_sancions_on_tipo_sancion"

  create_table "sci_servicios", force: :cascade do |t|
    t.string   "descripcion", limit: 4000
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "nota",        limit: 4000
    t.string   "servicio",    limit: 4000
  end

  add_index "sci_servicios", ["descripcion"], name: "index_sci_servicios_on_descripcion"

  create_table "servicio_contrato_adhesions", force: :cascade do |t|
    t.integer  "contrato_adhesions_id", limit: 4
    t.integer  "sci_servicios_id",      limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "servicio",              limit: 4000
  end

  add_index "servicio_contrato_adhesions", ["contrato_adhesions_id"], name: "index_servicio_contrato_adhesions_on_contrato_adhesions_id"
  add_index "servicio_contrato_adhesions", ["sci_servicios_id"], name: "index_servicio_contrato_adhesions_on_sci_servicios_id"

  create_table "servicio_habilitados", force: :cascade do |t|
    t.integer  "sciservicio_id",        limit: 4
    t.integer  "titulo_habilitante_id", limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "nota",                  limit: 4000
    t.string   "servicio",              limit: 4000
  end

  add_index "servicio_habilitados", ["sciservicio_id"], name: "index_servicio_habilitados_on_sciservicio_id"
  add_index "servicio_habilitados", ["titulo_habilitante_id"], name: "index_servicio_habilitados_on_titulo_habilitante_id"

  create_table "servicios_interconexions", force: :cascade do |t|
    t.decimal  "precio_interconexion",                          precision: 18, scale: 2
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "acuerdo_acceso_interconexions_id", limit: 4
    t.integer  "sci_servicios_id",                 limit: 4
    t.string   "servicio",                         limit: 4000
  end

  create_table "servicios_operadores_acuerdo_acceso_interconexions", force: :cascade do |t|
    t.decimal  "precio_interconexion",                                     precision: 18, scale: 0
    t.integer  "sci_servicios_id",                            limit: 4
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.integer  "operadores_acuerdo_acceso_interconexions_id", limit: 4
    t.string   "servicio",                                    limit: 4000
  end

  add_index "servicios_operadores_acuerdo_acceso_interconexions", ["operadores_acuerdo_acceso_interconexions_id"], name: "idx_servicios_op_aai"
  add_index "servicios_operadores_acuerdo_acceso_interconexions", ["sci_servicios_id"], name: "idx_operadores_aai_servicios"

  create_table "temp_sci_servicios", force: :cascade do |t|
    t.string   "descripcion", limit: 4000
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "nota",        limit: 4000
    t.string   "servicio",    limit: 4000
  end

  create_table "temp_servicio_habilitados", force: :cascade do |t|
    t.integer  "sciservicio_id",        limit: 4
    t.integer  "titulo_habilitante_id", limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "nota",                  limit: 4000
    t.string   "servicio",              limit: 4000
  end

  create_table "tipo_sancions", force: :cascade do |t|
    t.string   "tipo_sancion", limit: 4000
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "titulo_habilitantes", force: :cascade do |t|
    t.string   "numero_titulo",       limit: 4000
    t.date     "fecha_titulo"
    t.date     "fecha_notificacion"
    t.string   "causal_finalizacion", limit: 4000
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "espectrable_id",      limit: 4
    t.string   "espectrable_type",    limit: 4000
  end

  add_index "titulo_habilitantes", ["causal_finalizacion"], name: "index_titulo_habilitantes_on_causal_finalizacion"
  add_index "titulo_habilitantes", ["espectrable_id"], name: "index_titulo_habilitantes_on_espectrable_id"
  add_index "titulo_habilitantes", ["espectrable_type"], name: "index_titulo_habilitantes_on_espectrable_type"
  add_index "titulo_habilitantes", ["fecha_notificacion"], name: "index_titulo_habilitantes_on_fecha_notificacion"
  add_index "titulo_habilitantes", ["fecha_titulo"], name: "index_titulo_habilitantes_on_fecha_titulo"
  add_index "titulo_habilitantes", ["numero_titulo"], name: "index_titulo_habilitantes_on_numero_titulo"

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 4000
    t.string   "email",           limit: 4000
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "password_digest", limit: 4000
    t.string   "remember_digest", limit: 4000
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "zonas", force: :cascade do |t|
    t.string   "tipo_zona",             limit: 4000
    t.string   "descripcion_zona",      limit: 4000
    t.text     "nota",                  limit: 2147483647
    t.integer  "frecuenciaespectro_id", limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "provincia",             limit: 4000
    t.string   "canton",                limit: 4000
    t.string   "distrito",              limit: 4000
    t.integer  "autorizacions_id",      limit: 4
  end

  add_index "zonas", ["frecuenciaespectro_id"], name: "index_zonas_on_frecuenciaespectro_id"
  add_index "zonas", ["tipo_zona"], name: "index_zonas_on_tipo_zona"

  add_foreign_key "asientos", "operador_regulados", column: "operadorregulado_id"
  add_foreign_key "cantons", "provs"
  add_foreign_key "detalle_precios_tarifas", "precios_tarifas", column: "precios_tarifas_id", name: "FK_detalle_precios_tarifas_precios_tarifas"
  add_foreign_key "detalle_precios_tarifas", "sci_servicios", column: "sci_servicios_id", name: "FK_detalle_precios_tarifas_sci_servicios"
  add_foreign_key "detalle_recurso_numericos", "recurso_numericos", column: "recurso_numericos_id", name: "FK_detalle_recurso_numericos_recurso_numericos"
  add_foreign_key "distritos", "cantons"
  add_foreign_key "frecuencia_espectros", "espectros"
  add_foreign_key "operadores_acuerdo_acceso_interconexions", "acuerdo_acceso_interconexions", column: "acuerdo_acceso_interconexions_id", name: "FK_operadores_acuerdo_acceso_interconexions_acuerdo_acceso_interconexions"
  add_foreign_key "operadores_acuerdo_acceso_interconexions", "operador_regulados", column: "operador_regulados_id", name: "FK_operadores_acuerdo_acceso_interconexions_operador_regulados"
  add_foreign_key "operadores_convenio_ubicacion_equipos", "convenio_ubicacion_equipos", column: "convenio_ubicacion_equipos_id", name: "FK_operadores_convenio_ubicacion_equipos_convenio_ubicacion_equipos"
  add_foreign_key "operadores_convenio_ubicacion_equipos", "operadores_convenio_ubicacion_equipos", column: "id", name: "FK_operadores_convenio_ubicacion_equipos_operadores_convenio_ubicacion_equipos"
  add_foreign_key "operadores_orden_acceso_interconexions", "operador_regulados", column: "operador_regulados_id", name: "FK_operadores_orden_acceso_interconexions_operador_regulados"
  add_foreign_key "operadores_orden_acceso_interconexions", "orden_acceso_interconexions", column: "orden_acceso_interconexions_id", name: "FK_operadores_orden_acceso_interconexions_orden_acceso_interconexions"
  add_foreign_key "operadores_resolucion_ubicacion_equipos", "operador_regulados", column: "operador_regulados_id", name: "FK_operadores_resolucion_ubicacion_equipos_operador_regulados"
  add_foreign_key "operadores_resolucion_ubicacion_equipos", "resolucion_ubicacion_equipos", column: "resolucion_ubicacion_equipos_id", name: "FK_operadores_resolucion_ubicacion_equipos_resolucion_ubicacion_equipos"
  add_foreign_key "servicio_contrato_adhesions", "contrato_adhesions", column: "contrato_adhesions_id", name: "FK_servicio_contrato_adhesions_contrato_adhesions"
  add_foreign_key "servicio_contrato_adhesions", "sci_servicios", column: "sci_servicios_id", name: "FK_servicio_contrato_adhesions_sci_servicios"
  add_foreign_key "servicio_habilitados", "titulo_habilitantes"
  add_foreign_key "servicios_interconexions", "sci_servicios", column: "sci_servicios_id", name: "FK_servicios_interconexions_sci_servicios"
  add_foreign_key "servicios_interconexions", "servicios_interconexions", column: "id", name: "FK_servicios_interconexions_servicios_interconexions"
  add_foreign_key "servicios_operadores_acuerdo_acceso_interconexions", "sci_servicios", column: "sci_servicios_id", name: "FK_servicios_operadores_acuerdo_acceso_interconexions_sci_servicios"
  add_foreign_key "zonas", "autorizacions", column: "autorizacions_id", name: "FK_zonas_autorizacions"
end
