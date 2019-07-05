Rails.application.routes.draw do
  resources :bottle_racks
  resources :wines do
    resources :millesimes, except: %i[index] do
      resources :wlogs, except: %i[index show]
    end
  end
  resources :providers
  resources :producers
  resources :colors, except: %i[show]
  resources :countries, except: %i[show] do
    resources :regions
  end

  get 'admin/main'
  root 'admin#main'
end
