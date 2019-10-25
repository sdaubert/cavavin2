Rails.application.routes.draw do
  resources :dishes do
    member do
      get :select_regions
      post :save_regions
    end
  end
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
  resources :colors, except: %i[show] do
    collection do
      get :stats
    end
  end
  resources :countries, except: %i[show] do
    collection do
      get :stats
    end
    resources :regions do
      collection do
        get :country_stats
      end
      member do
        get :stats
      end
    end
  end

  get 'admin/main'
  get 'admin/book'
  get 'admin/stats'
  get 'admin/search'
  root 'admin#main'
end
