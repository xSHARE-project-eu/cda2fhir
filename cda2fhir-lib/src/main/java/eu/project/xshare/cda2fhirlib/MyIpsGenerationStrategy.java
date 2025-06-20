package eu.project.xshare.cda2fhirlib;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.jpa.ips.api.IpsContext;
import ca.uhn.fhir.jpa.ips.api.Section;
import ca.uhn.fhir.jpa.ips.jpa.JpaSectionSearchStrategyCollection;
import ca.uhn.fhir.jpa.ips.jpa.section.DiagnosticResultsJpaSectionSearchStrategyDiagnosticReport;
import ca.uhn.fhir.jpa.ips.jpa.section.DiagnosticResultsJpaSectionSearchStrategyObservation;
import ca.uhn.fhir.jpa.ips.jpa.section.MedicationSummaryJpaSectionSearchStrategyMedicationAdministration;
import ca.uhn.fhir.jpa.ips.jpa.section.MedicationSummaryJpaSectionSearchStrategyMedicationDispense;
import ca.uhn.fhir.jpa.ips.jpa.section.MedicationSummaryJpaSectionSearchStrategyMedicationRequest;
import ca.uhn.fhir.jpa.ips.jpa.section.MedicationSummaryJpaSectionSearchStrategyMedicationStatement;
import ca.uhn.fhir.jpa.ips.strategy.AllergyIntoleranceNoInfoR4Generator;
import ca.uhn.fhir.jpa.ips.strategy.BaseIpsGenerationStrategy;
import ca.uhn.fhir.jpa.ips.strategy.MedicationNoInfoR4Generator;
import ca.uhn.fhir.jpa.ips.strategy.ProblemNoInfoR4Generator;
import ca.uhn.fhir.jpa.term.api.ITermLoaderSvc;
import ca.uhn.fhir.rest.api.server.RequestDetails;
import ca.uhn.fhir.rest.param.TokenParam;
import ca.uhn.fhir.rest.server.exceptions.InvalidRequestException;
import eu.project.xshare.cda2fhirlib.section.*;
import jakarta.annotation.Nonnull;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.function.Function;
import lombok.Setter;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.instance.model.api.IIdType;
import org.hl7.fhir.r4.model.Address;
import org.hl7.fhir.r4.model.AllergyIntolerance;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.CarePlan;
import org.hl7.fhir.r4.model.ClinicalImpression;
import org.hl7.fhir.r4.model.Condition;
import org.hl7.fhir.r4.model.Consent;
import org.hl7.fhir.r4.model.DeviceUseStatement;
import org.hl7.fhir.r4.model.DiagnosticReport;
import org.hl7.fhir.r4.model.IdType;
import org.hl7.fhir.r4.model.Immunization;
import org.hl7.fhir.r4.model.MedicationAdministration;
import org.hl7.fhir.r4.model.MedicationDispense;
import org.hl7.fhir.r4.model.MedicationRequest;
import org.hl7.fhir.r4.model.MedicationStatement;
import org.hl7.fhir.r4.model.Observation;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Procedure;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.thymeleaf.util.Validate;

public class MyIpsGenerationStrategy extends BaseIpsGenerationStrategy {

  public static final String CUSTOM_IPS_NARRATIVES_PROPERTIES =
      "classpath:ips/ips-narratives.properties";

  public static final String SECTION_CODE_ALLERGY_INTOLERANCE = "48765-2";
  public static final String SECTION_CODE_MEDICATION_SUMMARY = "10160-0";
  public static final String SECTION_CODE_PROBLEM_LIST = "11450-4";
  public static final String SECTION_CODE_IMMUNIZATIONS = "11369-6";
  public static final String SECTION_CODE_PROCEDURES = "47519-4";
  public static final String SECTION_CODE_MEDICAL_DEVICES = "46264-8";
  public static final String SECTION_CODE_DIAGNOSTIC_RESULTS = "30954-2";
  public static final String SECTION_CODE_VITAL_SIGNS = "8716-3";
  public static final String SECTION_CODE_PREGNANCY = "10162-6";
  public static final String SECTION_CODE_SOCIAL_HISTORY = "29762-2";
  public static final String SECTION_CODE_ILLNESS_HISTORY = "11348-0";
  public static final String SECTION_CODE_FUNCTIONAL_STATUS = "47420-5";
  public static final String SECTION_CODE_PLAN_OF_CARE = "18776-5";
  public static final String SECTION_CODE_ADVANCE_DIRECTIVES = "42348-3";
  public static final String SECTION_SYSTEM_LOINC = ITermLoaderSvc.LOINC_URI;
  private final List<Function<Section, Section>> myGlobalSectionCustomizers = new ArrayList<>();

  private final FhirContext myFhirContext;

  private boolean myInitialized;

  @Setter private Bundle resourcesBundle;

  public MyIpsGenerationStrategy(FhirContext myFhirContext) {
    this.myFhirContext = myFhirContext;
  }

  public void addGlobalSectionCustomizer(@Nonnull Function<Section, Section> theCustomizer) {
    Validate.isTrue(
        !myInitialized, "This method must not be called after the strategy is initialized");
    Validate.notNull(theCustomizer, "theCustomizer must not be null");
    myGlobalSectionCustomizers.add(theCustomizer);
  }

  @Override
  public List<String> getNarrativePropertyFiles() {
    return List.of(CUSTOM_IPS_NARRATIVES_PROPERTIES);
  }

  @Override
  public IIdType massageResourceId(
      @Nullable IpsContext theIpsContext, @NotNull IBaseResource theResource) {
    return IdType.newRandomUuid();
  }

  @Override
  public IBaseResource createAuthor() {
    Organization organization = new Organization();
    organization
        .setName("eHealthPass - Gnomon Informatics S.A.")
        .addAddress(
            new Address()
                .addLine("Marinou Antipa 35")
                .setCity("Thessaloniki")
                .setPostalCode("55535")
                .setCountry("GR"))
        .setId(IdType.newRandomUuid());
    return organization;
  }

  @Override
  public final void initialize() {
    Validate.isTrue(!myInitialized, "Strategy must not be initialized twice");
    Validate.isTrue(myFhirContext != null, "No FhirContext has been supplied");
    Validate.isTrue(resourcesBundle != null, "No ResourcesBundle has been supplied");
    addSections();
    myInitialized = true;
  }

  @Nonnull
  @Override
  public IBaseResource fetchPatient(IIdType thePatientId, RequestDetails theRequestDetails) {
    return resourcesBundle.getEntry().stream()
        .map(Bundle.BundleEntryComponent::getResource)
        .filter(Patient.class::isInstance)
        .map(Patient.class::cast)
        .findFirst()
        .orElseThrow(() -> new InvalidRequestException("No Patient could be found in the bundle"));
  }

  @Nonnull
  @Override
  public IBaseResource fetchPatient(
      TokenParam thePatientIdentifier, RequestDetails theRequestDetails) {
    return fetchPatient((IIdType) null, theRequestDetails);
  }

  protected void addSections() {
    addJpaSectionAllergyIntolerance();
    addJpaSectionMedicationSummary();
    addJpaSectionProblemList();
    addJpaSectionImmunizations();
    addJpaSectionProcedures();
    addJpaSectionMedicalDevices();
    addJpaSectionDiagnosticResults();
    addJpaSectionVitalSigns();
    addJpaSectionPregnancy();
    addJpaSectionSocialHistory();
    addJpaSectionIllnessHistory();
    addJpaSectionFunctionalStatus();
    addJpaSectionPlanOfCare();
    addJpaSectionAdvanceDirectives();
  }

  protected void addJpaSectionAllergyIntolerance() {
    Section section =
        Section.newBuilder()
            .withTitle("Allergies and Intolerances")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_ALLERGY_INTOLERANCE)
            .withSectionDisplay("Allergies and adverse reactions Document")
            .withResourceType(AllergyIntolerance.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionAllergies")
            .withNoInfoGenerator(new AllergyIntoleranceNoInfoR4Generator())
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(
                AllergyIntolerance.class, new MyAllergyIntoleranceJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionMedicationSummary() {
    Section section =
        Section.newBuilder()
            .withTitle("Medication List")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_MEDICATION_SUMMARY)
            .withSectionDisplay("History of Medication use Narrative")
            .withResourceType(MedicationStatement.class)
            .withResourceType(MedicationRequest.class)
            .withResourceType(MedicationAdministration.class)
            .withResourceType(MedicationDispense.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionMedications")
            .withNoInfoGenerator(new MedicationNoInfoR4Generator())
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(
                MedicationAdministration.class,
                new MedicationSummaryJpaSectionSearchStrategyMedicationAdministration())
            .addStrategy(
                MedicationDispense.class,
                new MedicationSummaryJpaSectionSearchStrategyMedicationDispense())
            .addStrategy(
                MedicationRequest.class,
                new MedicationSummaryJpaSectionSearchStrategyMedicationRequest())
            .addStrategy(
                MedicationStatement.class,
                new MedicationSummaryJpaSectionSearchStrategyMedicationStatement())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionProblemList() {
    Section section =
        Section.newBuilder()
            .withTitle("Problem List")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_PROBLEM_LIST)
            .withSectionDisplay("Problem list - Reported")
            .withResourceType(Condition.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionProblems")
            .withNoInfoGenerator(new ProblemNoInfoR4Generator())
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Condition.class, new MyProblemListJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionImmunizations() {
    Section section =
        Section.newBuilder()
            .withTitle("History of Immunizations")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_IMMUNIZATIONS)
            .withSectionDisplay("History of Immunization Narrative")
            .withResourceType(Immunization.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionImmunizations")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Immunization.class, new MyImmunizationsJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionProcedures() {
    Section section =
        Section.newBuilder()
            .withTitle("History of Procedures")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_PROCEDURES)
            .withSectionDisplay("History of Procedures Document")
            .withResourceType(Procedure.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionProceduresHx")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Procedure.class, new MyProceduresJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionMedicalDevices() {
    Section section =
        Section.newBuilder()
            .withTitle("Medical Devices")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_MEDICAL_DEVICES)
            .withSectionDisplay("History of medical device use")
            .withResourceType(DeviceUseStatement.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionMedicalDevices")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(DeviceUseStatement.class, new MyMedicalDevicesJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionDiagnosticResults() {
    Section section =
        Section.newBuilder()
            .withTitle("Diagnostic Results")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_DIAGNOSTIC_RESULTS)
            .withSectionDisplay("Relevant diagnostic tests/laboratory data Narrative")
            .withResourceType(DiagnosticReport.class)
            .withResourceType(Observation.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionResults")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(
                DiagnosticReport.class,
                new DiagnosticResultsJpaSectionSearchStrategyDiagnosticReport())
            .addStrategy(
                Observation.class, new DiagnosticResultsJpaSectionSearchStrategyObservation())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionVitalSigns() {
    Section section =
        Section.newBuilder()
            .withTitle("Vital Signs")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_VITAL_SIGNS)
            .withSectionDisplay("Vital signs")
            .withResourceType(Observation.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionVitalSigns")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Observation.class, new MyVitalSignsJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionPregnancy() {
    Section section =
        Section.newBuilder()
            .withTitle("Pregnancy Information")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_PREGNANCY)
            .withSectionDisplay("History of pregnancies Narrative")
            .withResourceType(Observation.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionPregnancyHx")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Observation.class, new MyPregnancyJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionSocialHistory() {
    Section section =
        Section.newBuilder()
            .withTitle("Social History")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_SOCIAL_HISTORY)
            .withSectionDisplay("Social history Narrative")
            .withResourceType(Observation.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionSocialHistory")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Observation.class, new MySocialHistoryJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionIllnessHistory() {
    Section section =
        Section.newBuilder()
            .withTitle("History of Past Illness")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_ILLNESS_HISTORY)
            .withSectionDisplay("History of Past illness Narrative")
            .withResourceType(Condition.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionPastIllnessHx")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Condition.class, new MyIllnessHistoryJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionFunctionalStatus() {
    Section section =
        Section.newBuilder()
            .withTitle("Functional Status")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_FUNCTIONAL_STATUS)
            .withSectionDisplay("Functional status assessment note")
            .withResourceType(ClinicalImpression.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionFunctionalStatus")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(ClinicalImpression.class, new MyFunctionalStatusJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionPlanOfCare() {
    Section section =
        Section.newBuilder()
            .withTitle("Plan of Care")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_PLAN_OF_CARE)
            .withSectionDisplay("Plan of care note")
            .withResourceType(CarePlan.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionPlanOfCare")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(CarePlan.class, new MyPlanOfCareJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSectionAdvanceDirectives() {
    Section section =
        Section.newBuilder()
            .withTitle("Advance Directives")
            .withSectionSystem(SECTION_SYSTEM_LOINC)
            .withSectionCode(SECTION_CODE_ADVANCE_DIRECTIVES)
            .withSectionDisplay("Advance directives")
            .withResourceType(Consent.class)
            .withProfile(
                "https://hl7.org/fhir/uv/ips/StructureDefinition-Composition-uv-ips-definitions.html#Composition.section:sectionAdvanceDirectives")
            .build();

    JpaSectionSearchStrategyCollection searchStrategyCollection =
        JpaSectionSearchStrategyCollection.newBuilder()
            .addStrategy(Consent.class, new MyAdvanceDirectivesJpaSectionSearchStrategy())
            .build();

    addJpaSection(section, searchStrategyCollection);
  }

  protected void addJpaSection(
      Section theSection, JpaSectionSearchStrategyCollection theSectionSearchStrategyCollection) {
    Section section = theSection;
    for (var next : myGlobalSectionCustomizers) {
      section = next.apply(section);
    }

    Validate.isTrue(
        theSection.getResourceTypes().size()
            == theSectionSearchStrategyCollection.getResourceTypes().size(),
        "Search strategy types does not match section types");
    Validate.isTrue(
        new HashSet<>(theSection.getResourceTypes())
            .containsAll(theSectionSearchStrategyCollection.getResourceTypes()),
        "Search strategy types does not match section types");

    addSection(
        section,
        new MySectionResourceSupplier(
            theSectionSearchStrategyCollection, resourcesBundle, myFhirContext));
  }
}
