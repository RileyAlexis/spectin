Rails.application.routes.draw do
  get "pages/home"
  get "library", to: "library#index"
  get "library/books/:id/cover", to: "library#cover", as: :library_book_cover
  get "library/books/:id/reader", to: "library#reader", as: :library_book_reader
  get "library/books/:id/epub", to: "library#epub", as: :library_book_epub
  get "library/books/:id/reading_progress", to: "library#reading_progress", as: :library_book_reading_progress
  patch "library/books/:id/reading_progress", to: "library#update_reading_progress"
  get "epub_preview", to: "pages#epub_preview"
  post "epub_preview", to: "pages#epub_preview_upload"
  get "epub_preview_assets/:preview_id/*asset_path", to: "pages#epub_preview_asset", as: :epub_preview_asset, format: false
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
end
