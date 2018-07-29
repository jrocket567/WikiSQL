function patient = patient_query_1(lastname,name)
c={lastname,name};
str = strjoin(c,{'&given='});
fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir2 = 'Patient?family=';
d={fhir,fhir2,str};
string = strjoin(d);
string = string(~isspace(string));
data=webread(string);

patientname = [data.entry(1).resource.name.text];
%get the ID%
ID = [data.entry(1).resource.id];

fhir2 = 'AllergyIntolerance?patient=';
d={fhir,fhir2,ID};
string = strjoin(d);
string = string(~isspace(string));
data=webread(string);

allergy = [data.entry(1).resource.substance.text];
reaction = [data.entry(2).resource.reaction.manifestation.text];
substance = [data.entry(2).resource.substance.text];

fhir2 = 'MedicationOrder?patient=';
d={fhir,fhir2,ID};
string = strjoin(d);
string = string(~isspace(string));
data=webread(string);

medication = [data.entry(1).resource.medicationReference.display];
instruction = [data.entry(1).resource.dosageInstruction.text];

fhir2 = 'Condition?patient=';
d={fhir,fhir2,ID};
string = strjoin(d);
string = string(~isspace(string));
data=webread(string);

condition = [data.entry(1).resource.code.text];
severity = [data.entry(1).resource.severity.text];

fhir2 = 'FamilyMemberHistory?patient=';
d={fhir,fhir2,ID};
string = strjoin(d);
string = string(~isspace(string));
data=webread(string);

familyhistoryrel = [data.entry(1).resource.relationship.text];
familyhistorycond = [data.entry(1).resource.condition.code.text];

fhir2 = 'Observation?patient=';
obs = '&code=8310-5';
d={fhir,fhir2,ID,obs};
string = strjoin(d);
string = string(~isspace(string));
data=webread(string);

observationtype = [data.entry(1).resource.code.text];
observationval = [data.entry(1).resource.valueQuantity.value];
Units = [data.entry(1).resource.valueQuantity.unit];
nurse = [data.entry(1).resource.performer.display];

patient = struct('given',[],'allergy',[],'manifestation',[],'medication',[],'condition',[],'severity',[],'familyhist1',[],'familyhist2',[],'type',[],'valueQuantity',[],'valueQuantityunits',[],'performer',[]);
patient(1).given=[patientname];
patient(1).allergy=[allergy];
patient(1).manifestation=[reaction];
patient(1).medication=[medication];
patient(1).condition=[condition];
patient(1).severity=[severity];
patient(1).familyhist1=[familyhistoryrel];
patient(1).familyhist2=[familyhistorycond];
patient(1).type=[observationtype];
patient(1).valueQuantity=[observationval];
patient(1).valueQuantityunits=[Units];
patient(1).performer=[nurse];