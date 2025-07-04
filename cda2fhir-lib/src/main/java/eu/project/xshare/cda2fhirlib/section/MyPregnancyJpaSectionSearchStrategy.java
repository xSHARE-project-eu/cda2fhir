/*-
 * #%L
 * HAPI FHIR JPA Server - International Patient Summary (IPS)
 * %%
 * Copyright (C) 2014 - 2025 Smile CDR, Inc.
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package eu.project.xshare.cda2fhirlib.section;

import static ca.uhn.fhir.jpa.term.api.ITermLoaderSvc.LOINC_URI;

import ca.uhn.fhir.jpa.ips.api.IpsSectionContext;
import ca.uhn.fhir.jpa.ips.jpa.JpaSectionSearchStrategy;
import ca.uhn.fhir.jpa.searchparam.SearchParameterMap;
import ca.uhn.fhir.rest.param.TokenOrListParam;
import ca.uhn.fhir.rest.param.TokenParam;
import jakarta.annotation.Nonnull;
import org.hl7.fhir.r4.model.Observation;

public class MyPregnancyJpaSectionSearchStrategy extends JpaSectionSearchStrategy<Observation> {

  public static final String LOINC_CODE_PREGNANCY_STATUS = "82810-3";
  public static final String LOINC_CODE_NUMBER_BIRTHS_LIVE = "11636-8";
  public static final String LOINC_CODE_NUMBER_BIRTHS_PRETERM = "11637-6";
  public static final String LOINC_CODE_NUMBER_BIRTHS_STILL_LIVING = "11638-4";
  public static final String LOINC_CODE_NUMBER_BIRTHS_TERM = "11639-2";
  public static final String LOINC_CODE_NUMBER_BIRTHS_TOTAL = "11640-0";
  public static final String LOINC_CODE_NUMBER_ABORTIONS = "11612-9";
  public static final String LOINC_CODE_NUMBER_ABORTIONS_INDUCED = "11613-7";
  public static final String LOINC_CODE_NUMBER_ABORTIONS_SPONTANEOUS = "11614-5";
  public static final String LOINC_CODE_NUMBER_ECTOPIC_PREGNANCY = "33065-4";

  @Override
  public void massageResourceSearch(
      @Nonnull IpsSectionContext<Observation> theIpsSectionContext,
      @Nonnull SearchParameterMap theSearchParameterMap) {
    theSearchParameterMap.add(
        Observation.SP_CODE,
        new TokenOrListParam()
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_PREGNANCY_STATUS))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_LIVE))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_PRETERM))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_STILL_LIVING))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_TERM))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_TOTAL))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_ABORTIONS))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_ABORTIONS_INDUCED))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_ABORTIONS_SPONTANEOUS))
            .addOr(new TokenParam(LOINC_URI, LOINC_CODE_NUMBER_ECTOPIC_PREGNANCY)));
  }

  @SuppressWarnings("RedundantIfStatement")
  @Override
  public boolean shouldInclude(
      @Nonnull IpsSectionContext<Observation> theIpsSectionContext,
      @Nonnull Observation theCandidate) {
    // code filtering not yet applied
    if (theCandidate.getStatus() != Observation.ObservationStatus.PRELIMINARY
        && isPregnancyObservation(theCandidate)) {
      return true;
    }

    return false;
  }

  private boolean isPregnancyObservation(Observation observation) {
    return observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_PREGNANCY_STATUS)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_LIVE)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_PRETERM)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_STILL_LIVING)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_TERM)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_BIRTHS_TOTAL)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_ABORTIONS)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_ABORTIONS_INDUCED)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_ABORTIONS_SPONTANEOUS)
        || observation.getCode().hasCoding(LOINC_URI, LOINC_CODE_NUMBER_ECTOPIC_PREGNANCY);
  }
}
