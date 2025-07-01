pin "application", to: "pin_flags/application.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from PinFlags::Engine.root.join("app/javascript/pin_flags/controllers"), under: "controllers", to: "pin_flags/controllers"
