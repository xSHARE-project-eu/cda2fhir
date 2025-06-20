package eu.project.xshare.cda2fhirlib;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.jpa.ips.api.ISectionResourceSupplier;
import ca.uhn.fhir.jpa.ips.api.IpsContext;
import ca.uhn.fhir.jpa.ips.api.IpsSectionContext;
import ca.uhn.fhir.jpa.ips.jpa.IJpaSectionSearchStrategy;
import ca.uhn.fhir.jpa.ips.jpa.JpaSectionSearchStrategyCollection;
import ca.uhn.fhir.model.api.ResourceMetadataKeyEnum;
import ca.uhn.fhir.model.valueset.BundleEntrySearchModeEnum;
import ca.uhn.fhir.rest.api.server.RequestDetails;
import jakarta.annotation.Nonnull;
import java.util.ArrayList;
import java.util.List;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Resource;
import org.jetbrains.annotations.Nullable;
import org.thymeleaf.util.Validate;

public class MySectionResourceSupplier implements ISectionResourceSupplier {

  private final JpaSectionSearchStrategyCollection mySectionSearchStrategyCollection;

  private final Bundle resourcesBundle;

  private final FhirContext myFhirContext;

  public MySectionResourceSupplier(
      @Nonnull JpaSectionSearchStrategyCollection theSectionSearchStrategyCollection,
      @Nonnull Bundle theResourcesBundle,
      @Nonnull FhirContext theFhirContext) {
    Validate.notNull(
        theSectionSearchStrategyCollection, "theSectionSearchStrategyCollection must not be null");
    Validate.notNull(theResourcesBundle, "theResourcesBundle must not be null");
    Validate.notNull(theFhirContext, "theFhirContext must not be null");
    mySectionSearchStrategyCollection = theSectionSearchStrategyCollection;
    resourcesBundle = theResourcesBundle;
    myFhirContext = theFhirContext;
  }

  @Override
  public @Nullable <T extends IBaseResource> List<ResourceEntry> fetchResourcesForSection(
      IpsContext theIpsContext,
      IpsSectionContext<T> theIpsSectionContext,
      RequestDetails theRequestDetails) {
    IJpaSectionSearchStrategy<T> searchStrategy =
        mySectionSearchStrategyCollection.getSearchStrategy(theIpsSectionContext.getResourceType());

    // TODO We need to filter by search params (like in JpaSectionResourceSupplier)
    // Probably we need to implement one JpaSectionSearchStrategy for each IPS resource
    // Actually we need custom implementations for JpaSectionSearchStrategyCollection and
    // IJpaSectionSearchStrategy

    List<ResourceEntry> retVal = null;
    List<Resource> resources =
        resourcesBundle.getEntry().stream()
            .map(Bundle.BundleEntryComponent::getResource)
            .filter(theIpsSectionContext.getResourceType()::isInstance)
            .toList();

    for (IBaseResource next : resources) {
      if (!next.getClass().isAssignableFrom(theIpsSectionContext.getResourceType())
          || searchStrategy.shouldInclude(theIpsSectionContext, (T) next)) {
        if (retVal == null) {
          retVal = new ArrayList<>();
        }
        InclusionTypeEnum inclusionType =
            ResourceMetadataKeyEnum.ENTRY_SEARCH_MODE.get(next) == BundleEntrySearchModeEnum.INCLUDE
                ? InclusionTypeEnum.SECONDARY_RESOURCE
                : InclusionTypeEnum.PRIMARY_RESOURCE;
        retVal.add(new ResourceEntry(next, inclusionType));
      }
    }

    return retVal;
  }
}
