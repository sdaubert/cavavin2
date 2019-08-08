module WinesHelper
  def build_params(h={})
    logger.debug @url_params.inspect
    @url_params.merge(h)
  end
end
