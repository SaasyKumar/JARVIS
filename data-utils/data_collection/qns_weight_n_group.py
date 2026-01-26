import pandas as pd
dataframe1 = pd.read_excel('/test_files/uday-sampleset.xlsx')

#for columnar data
qnlist = []
for index, row in dataframe1.iterrows():
  qnlist.append(row.Number)
print(qnlist)
#gives all data in 1st column -> title

#for row data -> candidate or user name
participants =[]
for col in dataframe1.columns:
  if col != "Number":
    participants.append(col)
print(participants)

#TODO: All input needed
max_score = 6
direct_qn = ["Q11","Q33"]
no_of_groups = 3
active_grief=["Q1","Q3","Q5","Q6","Q7","Q10","Q12","Q13","Q14","Q19","Q27"]
difficult_coping=["Q2","Q4","Q8","Q11","Q21","Q24","Q25","Q26","Q28","Q30","Q33"]
#TODO: why not variables based on input?
breaks =["Q13","Q25"] #Prints score at these points for debug
print(len(active_grief))
print(len(difficult_coping))
print(len(qnlist))

#output
outputlist=[]
for participant in participants:
  total_score = 0
  ag = 0
  dc = 0
  desp = 0
  lst = [participant]
  for index, row in dataframe1.iterrows():
    if row[participant] and row.Number in qnlist: #participant =="Dolly Gracy" and for debug
      score =0
      if row.Number in direct_qn:
        score += row[participant]
      else:
        score += max_score - row[participant]
      total_score += score
      # print(score) for debug
      #groups
      if row.Number in active_grief:
        ag += score
      elif row.Number in difficult_coping:
        dc += score
      else:
        desp += score
      # breaks to show page value for debug
      # if row.Number in breaks:
      #   print(f'break: {total_score}')
  print(f'Total score of {participant} is {total_score}')
  print(f'Active Grief: {ag}')
  print(f'Difficult coping: {dc}')
  print(f'Despair: {desp}')
  outputlist.append([participant,str(total_score),str(ag),str(dc),str(desp)])

from excelcopy import listToTSV
print(listToTSV(outputlist))