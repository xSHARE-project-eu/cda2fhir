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

import ca.uhn.fhir.jpa.ips.api.IpsSectionContext;
import ca.uhn.fhir.jpa.ips.jpa.JpaSectionSearchStrategy;
import ca.uhn.fhir.jpa.searchparam.SearchParameterMap;
import ca.uhn.fhir.rest.param.TokenOrListParam;
import ca.uhn.fhir.rest.param.TokenParam;
import jakarta.annotation.Nonnull;
import org.hl7.fhir.r4.model.MedicationDispense;
import org.jetbrains.annotations.NotNull;

public class MyMedicationSummaryJpaSectionSearchStrategyMedicationDispense
    extends JpaSectionSearchStrategy<MedicationDispense> {

  @Override
  public void massageResourceSearch(
      @Nonnull IpsSectionContext<MedicationDispense> theIpsSectionContext,
      @Nonnull SearchParameterMap theSearchParameterMap) {
    theSearchParameterMap.addInclude(MedicationDispense.INCLUDE_MEDICATION);
    theSearchParameterMap.add(
        MedicationDispense.SP_STATUS,
        new TokenOrListParam()
            .addOr(
                new TokenParam(
                    MedicationDispense.MedicationDispenseStatus.INPROGRESS.getSystem(),
                    MedicationDispense.MedicationDispenseStatus.INPROGRESS.toCode()))
            .addOr(
                new TokenParam(
                    MedicationDispense.MedicationDispenseStatus.UNKNOWN.getSystem(),
                    MedicationDispense.MedicationDispenseStatus.UNKNOWN.toCode()))
            .addOr(
                new TokenParam(
                    MedicationDispense.MedicationDispenseStatus.ONHOLD.getSystem(),
                    MedicationDispense.MedicationDispenseStatus.ONHOLD.toCode())));
  }

  @SuppressWarnings("RedundantIfStatement")
  @Override
  public boolean shouldInclude(
      @NotNull IpsSectionContext<MedicationDispense> theIpsSectionContext,
      @NotNull MedicationDispense theCandidate) {
    if (theCandidate.getStatus() == MedicationDispense.MedicationDispenseStatus.INPROGRESS
        || theCandidate.getStatus() == MedicationDispense.MedicationDispenseStatus.UNKNOWN
        || theCandidate.getStatus() == MedicationDispense.MedicationDispenseStatus.ONHOLD) {
      return true;
    }

    return false;
  }
}
