module WinesHelper
  def build_params(h={})
    @url_params.merge(h)
  end
end
