const chai = require("chai");
const chaiHttp = require("chai-http");
const sinon = require("sinon");

const db = require("../webapp/db");
const app = require("../webapp/index");

const expect = chai.expect;
chai.use(chaiHttp);
chai.should();

describe("Create user", function() {
    describe("Password does not meet criteria", function() {
        it("should return status 400 if password does not meet standards", (done) => {
            chai.request(app)
                .post("/v1/user/")
                .set("content-type", "application/json")
                .send({
                    email: "johndoe@northeastern.edu",
                    firstname: "John",
                    lastname: "Doe",
                    password: "password"
                })
                .end((err, res) => {
                    res.should.have.status(400);
                    done();
                });
        }); 
    });

    describe("Email already exists", function() {
        it("should return status 400 if email already exists", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [{
                email: "johndoe@northeastern.edu"
            }] }));

            chai.request(app)
                .post("/v1/user/")
                .set("content-type", "application/json")
                .send({
                    email: "johndoe@northeastern.edu",
                    firstname: "John",
                    lastname: "Doe",
                    password: "Password1234"
                })
                .end((err, res) => {
                    res.should.have.status(400);
                    // res.error.text.should.be.equal("Email already exists")
                    done();
                });
        }); 

        after(function() {
            db.getAllEmail.restore();
        });
    });

    describe("New user created", function() {
        it("should return status 201 if user created", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [] }));
            const createUserStub = sinon.stub(db, "createUser").callsFake(() => Promise.resolve());

            chai.request(app)
                .post("/v1/user/")
                .set("content-type", "application/json")
                .send({
                    email: "janedoe@northeastern.edu",
                    firstname: "Jane",
                    lastname: "Doe",
                    password: "Password1234"
                })
                .end((err, res) => {
                    res.should.have.status(201);
                    expect(createUserStub.calledOnce).to.be.true;
                    done();
                });
        });

        after(function() {
            db.getAllEmail.restore();
            db.createUser.restore();
        });
    });
});

describe("Get User Details", function() {

    describe("User doesn't exist", function() {
        it("should return status 401 if user doesn't exist", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [] }));

            chai.request(app)
                .get("/v1/user/self/")
                .set("Authorization", "Basic c3VoYXNwYXNyaWNoYUBnbWFpbC5jb206UGFzc3dvcmQxMjM0")
                .end((err, res) => {
                    res.should.have.status(401);
                    done();
                })
        })

        after(function() {
            db.getAllEmail.restore();
        })
    })

    describe("Password doesn't match", function() {
        it("should return status 401 if password doesn't match", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [{
                email: "suhaspasricha@gmail.com"
            }] }));
            const getUserDetailsStub = sinon.stub(db, "getUserDetails").callsFake(() => Promise.resolve({ rows: [{
                password: "$2b$10$VCKdOXikH2ZAD8Q7GxaroeaBKte.5s.bzma1IgvMve6jAr6YBPRV8"
            }] }));

            chai.request(app)
                .get("/v1/user/self/")
                .set("authorization", "Basic c3VoYXNwYXNyaWNoYUBnbWFpbC5jb206UGFzc3dvcmQxMjM0")
                .end((err, res) => {
                    res.should.have.status(401);
                    done();
                });
        });

        after(function() {
            db.getAllEmail.restore();
            db.getUserDetails.restore();
        })
    });

    describe("Authorized successfully", function() {
        it("should return user details", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [{
                email: "suhaspasricha@gmail.com"
            }] }));
            const getUserDetailsStub = sinon.stub(db, "getUserDetails").callsFake(() => Promise.resolve({ rows: [{
                password: "$2b$10$5g6xmLPwiEpcS7AN9gfE7eraHT21aFUrkn40tlkcmE2at/gIQGOka",
                id: "a6895698-dceb-4050-af53-6d8e39fcd946",
                email: "suhaspasricha@gmail.com",
                firstname: "Suhas",
                lastname: "Pasricha",
                account_created: "2019-09-25T02:28:46.638Z",
                account_updated: "2019-09-25T02:28:46.638Z",
            }] }));

            chai.request(app)
                .get("/v1/user/self/")
                .set("authorization", "Basic c3VoYXNwYXNyaWNoYUBnbWFpbC5jb206UGFzc3dvcmQxMjM0")
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.should.be.deep.equal({
                        id: "a6895698-dceb-4050-af53-6d8e39fcd946",
                        email: "suhaspasricha@gmail.com",
                        firstname: "Suhas",
                        lastname: "Pasricha",
                        account_created: "2019-09-25T02:28:46.638Z",
                        account_updated: "2019-09-25T02:28:46.638Z",
                    })
                    done();
                });
        });

        after(function() {
            db.getAllEmail.restore();
            db.getUserDetails.restore();
        })
    });
});

describe("Update user", function() {
    afterEach(function() {
        db.getAllEmail.restore();
        db.getUserDetails.restore();
    });

    describe("Authorization failure", function() {
        it("should return status 401 if password is wrong", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [{
                email: "suhaspasricha@gmail.com"
            }] }));
            const getUserDetailsStub = sinon.stub(db, "getUserDetails").callsFake(() => Promise.resolve({ rows: [{
                password: "$2b$10$VCKdOXikH2ZAD8Q7GxaroeaBKte.5s.bzma1IgvMve6jAr6YBPRV8"
            }] }));

            chai.request(app)
                .put("/v1/user/self/")
                .set("authorization", "Basic c3VoYXNwYXNyaWNoYUBnbWFpbC5jb206UGFzc3dvcmQxMjM0")
                .send({
                    "firstname": "Jane"
                })
                .end((err, res) => {
                    res.should.have.status(401);
                    done();
                });
        })
    })

    describe("Update firstname", function() {
        after(function() {
            db.updateUserDetails.restore();
        })
        it("should return status code 204", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [{
                email: "suhaspasricha@gmail.com"
            }] }));
            const getUserDetailsStub = sinon.stub(db, "getUserDetails").callsFake(() => Promise.resolve({ rows: [{
                password: "$2b$10$5g6xmLPwiEpcS7AN9gfE7eraHT21aFUrkn40tlkcmE2at/gIQGOka",
                id: "a6895698-dceb-4050-af53-6d8e39fcd946",
                email: "suhaspasricha@gmail.com",
                firstname: "Suhas",
                lastname: "Pasricha",
                account_created: "2019-09-25T02:28:46.638Z",
                account_updated: "2019-09-25T02:28:46.638Z",
            }] }));

            const updateUserDetailsStub = sinon.stub(db, "updateUserDetails").callsFake(() => Promise.resolve());

            chai.request(app)
                .put("/v1/user/self/")
                .set("authorization", "Basic c3VoYXNwYXNyaWNoYUBnbWFpbC5jb206UGFzc3dvcmQxMjM0")
                .send({
                    "firstname": "Jane"
                })
                .end((err, res) => {
                    res.should.have.status(204);
                    done();
                });
        });
    });

    describe("Update password", function() {
        after(function() {
            db.updateUserDetails.restore();
        })
        it("should return status code 204", (done) => {
            const getAllEmailStub = sinon.stub(db, "getAllEmail").callsFake(() => Promise.resolve({ rows: [{
                email: "suhaspasricha@gmail.com"
            }] }));
            const getUserDetailsStub = sinon.stub(db, "getUserDetails").callsFake(() => Promise.resolve({ rows: [{
                password: "$2b$10$5g6xmLPwiEpcS7AN9gfE7eraHT21aFUrkn40tlkcmE2at/gIQGOka",
                id: "a6895698-dceb-4050-af53-6d8e39fcd946",
                email: "suhaspasricha@gmail.com",
                firstname: "Suhas",
                lastname: "Pasricha",
                account_created: "2019-09-25T02:28:46.638Z",
                account_updated: "2019-09-25T02:28:46.638Z",
            }] }));

            const updateUserDetailsStub = sinon.stub(db, "updateUserDetails").callsFake(() => Promise.resolve());

            chai.request(app)
                .put("/v1/user/self/")
                .set("authorization", "Basic c3VoYXNwYXNyaWNoYUBnbWFpbC5jb206UGFzc3dvcmQxMjM0")
                .send({
                    "password": "Passcode1234"
                })
                .end((err, res) => {
                    res.should.have.status(204);
                    done();
                });
        });
    });
})

