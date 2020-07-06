# module ErrorPages

  not_found do
    halt_error(404, message: 'Page not found.')
  end

  get '/error/:status' do
    halt_error((params[:status] || status), message: params[:message])
  end

  get '/error' do
    halt 404
  end

# end
# include ErrorPages