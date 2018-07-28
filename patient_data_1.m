function patient = patientdata(fhir)
fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir = [fhir 'Patient/Tbt3KuCY0B5PSrJvCu2j-PlK.aiHsu2xUjUM8bWpetXoB'];

data=webread(fhir);
name = getfield(data, 'name');

fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir = [fhir 'AllergyIntolerance/TPcWiBG2h2E114Vh0sRT8fQB'];

data=webread(fhir);
allergy = getfield(data, 'substance');
allergy = getfield(allergy, 'text');
reaction = getfield(data, 'reaction');
reaction = getfield(reaction, 'manifestation');

fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir = [fhir 'Medication/T0eKLT7EB2ApMM8HCEURdMAB'];

data=webread(fhir);
medication = getfield(data, 'code');
medication = getfield(medication, 'text');

fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir = [fhir 'Condition/T1kK.xqvU20cEJe860G4aKgB'];

data=webread(fhir);
condition = getfield(data, 'code');
condition = getfield(condition, 'text');
severity = getfield(data, 'severity');

fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir = [fhir 'FamilyMemberHistory?patient=Tbt3KuCY0B5PSrJvCu2j-PlK.aiHsu2xUjUM8bWpetXoB'];

data=webread(fhir);
familyhistory = getfield(data, 'entry');
familyhistory = getfield(familyhistory, 'resource');
familyhistoryrel = getfield(familyhistory, 'relationship');
familyhistorycond = getfield(familyhistory, 'condition');
familyhistorycond = getfield(familyhistorycond, 'code');

fhir = 'https://open-ic.epic.com/FHIR/api/FHIR/DSTU2/';
fhir = [fhir 'Observation/Tnf7t0.SP6znu2Dc1kPsron.8Qlu-yjOF792bUBX3SIbqfiRJTmZfK.seS16W01szB'];

data=webread(fhir);
observationtype = getfield(data, 'category');
observation = getfield(data, 'code');
observationval = getfield(data, 'valueQuantity');
nurse = getfield (data, 'performer');

patient = struct('family',[],'given',[],'allergy',[],'manifestation',[],'medication',[],'condition',[],'severity',[],'familyhist1',[],'familyhist2',[],'category',[],'code',[],'valueQuantity',[],'valueQuantityunits',[],'performer',[]);
patient(1).family = [name.family];
patient(1).given=[name.given];
patient(1).allergy=[allergy];
patient(1).manifestation=[reaction.text];
patient(1).medication=[medication];
patient(1).condition=[condition];
patient(1).severity=[severity.text];
patient(1).familyhist1=[familyhistoryrel.text];
patient(1).familyhist2=[familyhistorycond.text];
patient(1).category=[data.category.text];
patient(1).code=[data.code.text];
patient(1).valueQuantity=[data.valueQuantity.value];
patient(1).valueQuantityunits=[data.valueQuantity.unit];
patient(1).performer=[data.performer.display];

