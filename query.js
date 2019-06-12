rs.slaveOk()
printjson(db.durabilityTest.findOne({'key': 'foo'}))
