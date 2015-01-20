local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
   content = {
	  	fps = 30,
        width = 768,
        height = 1024,
        scale = "letterbox",
        antialias = true,
        imageSuffix =
        {
          ["@4x"] = 4,
        	  ["@2x"] = 2
        },        
   },
   notification = 
        {
            iphone =
            {
                types = { "badge", "sound", "alert" }
            },
            google =
            {
                -- This Project Number (also known as a Sender ID) tells Corona to register this application
                -- for push notifications with the Google Cloud Messaging service on startup.
                -- This number can be obtained from the Google API Console at:  https://code.google.com/apis/console
                projectNumber = "932327215902",
            },
        }
}