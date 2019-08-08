Rails.application.routes.draw do
  resources :bottle_racks do
    member do
      post :get_info
    end
  end
  resources :wines do
    resources :millesimes, except: %i[index] do
      resources :wlogs, except: %i[index show] do
        member do
          get :select_rack
          get :select_rack2
          post :save_rack
        end
      end
    end
  end
  resources :providers
  resources :producers
  resources :colors, except: %i[show]
  resources :countries, except: %i[show] do
    resources :regions
  end

  get 'admin/main'
  get 'admin/book'
  root 'admin#main'
end
