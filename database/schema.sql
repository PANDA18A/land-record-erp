-- ===========================================
-- LAND RECORD ERP DATABASE SCHEMA
-- Version : 1.0
-- Author  : PANDA18A
-- ===========================================


/*==========================================================
  MASTER TABLE : APPLICANT
==========================================================*/

CREATE TABLE applicant (
    applicant_id BIGSERIAL PRIMARY KEY,
    aadhaar_number VARCHAR(12) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(10),
    email VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);



/*==========================================================
  TRANSACTION TABLE : APPLICATION
==========================================================*/

CREATE TABLE application (
    application_id BIGSERIAL PRIMARY KEY,
    applicant_id BIGINT NOT NULL,
    application_type VARCHAR(50) NOT NULL,
    application_date DATE NOT NULL DEFAULT CURRENT_DATE,

    status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'UNDER_VERIFICATION',
                'APPROVED',
                'REJECTED'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_applicant
        FOREIGN KEY (applicant_id)
        REFERENCES applicant(applicant_id)
        ON DELETE RESTRICT
);



/*==========================================================
  MASTER TABLE : PLOT
==========================================================*/

CREATE TABLE plot (
    plot_id BIGSERIAL PRIMARY KEY,
    plot_number VARCHAR(50) NOT NULL,
    mouza VARCHAR(100) NOT NULL,
    jl_number VARCHAR(20) NOT NULL,
    area_decimal NUMERIC(10,2) NOT NULL,
    land_class VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_plot UNIQUE (plot_number, mouza)
);