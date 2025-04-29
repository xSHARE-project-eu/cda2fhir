package eu.project.xshare.cda2fhirlib;

import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import freemarker.template.TemplateModelException;

public class FreemarkerConfigFactory {

  private static final String TEMPLATE_PATH = "/templates/";

  public static Configuration defaultConfiguration() {
    Configuration freemarkerConfiguration = new Configuration(Configuration.VERSION_2_3_34);
    freemarkerConfiguration.setClassLoaderForTemplateLoading(
        FreemarkerConfigFactory.class.getClassLoader(), TEMPLATE_PATH);
    freemarkerConfiguration.setDefaultEncoding("UTF-8");
    freemarkerConfiguration.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

    try {
      freemarkerConfiguration.setSharedVariable("uuid", new UuidGenerator());

      return freemarkerConfiguration;
    } catch (TemplateModelException e) {
      throw new RuntimeException("Failed to initialize Freemarker freemarkerConfiguration", e);
    }
  }
}
