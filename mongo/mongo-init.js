db = db.getSiblingDB("msa");

db.createUser({
    user: "msaUser",
    pwd: "ubiqube38",
    roles: [
      {
        role: 'readWrite', 
        db: 'msa'
      },
    ],
  });
use("msa");

