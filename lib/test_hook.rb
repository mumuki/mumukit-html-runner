require_relative './test_dom_hook'
require_relative './test_script_hook'

class HtmlTestHook < Mumukit::Hook
  TEST_DOM_HOOK = HtmlTestDomHook.new
  TEST_SCRIPT_HOOK = HtmlTestScriptHook.new

  def compile(request)
    request = struct request.to_h.merge options: options(request)
    TEST_SCRIPT_HOOK.compile TEST_DOM_HOOK.compile(request)
  end

  def run!(request)
    dom_output, dom_status = TEST_DOM_HOOK.run! request
    script_test_results = TEST_SCRIPT_HOOK.run!(request)&.first

    if script_test_results.blank?
      [dom_output, dom_status]
    else
      [script_test_results, dom_output, dom_status] # TODO: Soportar testear scripts y no DOM
    end
  end

  private

  def options(request)
    return {} unless request.test.is_a?(Hash)

    options_yaml = request.test['options']
    return {} if options_yaml.blank?

    YAML.load(options_yaml)
  end
end
