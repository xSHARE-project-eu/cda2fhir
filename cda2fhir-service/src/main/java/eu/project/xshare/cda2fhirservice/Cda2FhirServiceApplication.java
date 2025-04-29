package eu.project.xshare.cda2fhirservice;

import eu.project.xshare.cda2fhirlib.Cda2FhirTransformer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class Cda2FhirServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(Cda2FhirServiceApplication.class, args);
  }

  @Bean
  public Cda2FhirTransformer cda2FhirTransformer() {
    return new Cda2FhirTransformer();
  }
}
