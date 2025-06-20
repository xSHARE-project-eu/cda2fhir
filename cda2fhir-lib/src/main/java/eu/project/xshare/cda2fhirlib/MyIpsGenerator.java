package eu.project.xshare.cda2fhirlib;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.jpa.ips.generator.IpsGeneratorSvcImpl;
import ca.uhn.fhir.rest.api.server.SystemRequestDetails;
import org.hl7.fhir.instance.model.api.IBaseBundle;
import org.hl7.fhir.instance.model.api.IIdType;
import org.hl7.fhir.r4.model.Bundle;

public class MyIpsGenerator extends IpsGeneratorSvcImpl {

  public MyIpsGenerator(FhirContext fhirContext, Bundle resourcesBundle) {
    super(fhirContext, generationStrategy(fhirContext, resourcesBundle));
  }

  public IBaseBundle generateIps() {
    return generateIps(new SystemRequestDetails(), (IIdType) null, null);
  }

  private static MyIpsGenerationStrategy generationStrategy(
      FhirContext fhirContext, Bundle resourcesBundle) {
    MyIpsGenerationStrategy strategy = new MyIpsGenerationStrategy(fhirContext);
    strategy.setResourcesBundle(resourcesBundle);

    return strategy;
  }
}
